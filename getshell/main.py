from argparse import ArgumentParser, Namespace
from pathlib import Path
from typing import Any, Generator

import base64
import importlib.resources
import json
import random
import shlex
import string
import subprocess

import jinja2
import jinja2.meta

from getshell import templates as templates_pkg

KNOWN_VARIABLES = {'LHOST', 'LPORT', 'RPORT', 'SRVURL'}


def main() -> None:
    entrypoint = ArgumentParser()
    for var in KNOWN_VARIABLES:
        entrypoint.add_argument(f'--{var.lower()}')
    entrypoint.add_argument('template', nargs='?')
    opts = entrypoint.parse_args()

    template_dir = get_template_dir()
    loader = jinja2.FileSystemLoader(template_dir)
    env = build_jinja_env(loader)
    assert env.loader  # make static analyzer happy

    if not opts.template:
        template_names = loader.list_templates()
        opts.template = fzf(template_names, prompt='template: ')

    content, *_ = env.loader.get_source(env, opts.template)
    variables = set(grep_variables(env, content))
    if unknown_variables := variables - KNOWN_VARIABLES:
        print(f'template {opts.template} contains unknown variable: {", ".join(unknown_variables)}')
        exit(1)

    replacements = ask_variables(opts, variables)

    print(render_jinja(env, content, replacements))


def get_template_dir() -> Path:
    # something like importlib.resources.as_dir does not exist
    with importlib.resources.as_file(next(importlib.resources.files(templates_pkg).iterdir())) as file:
        return file.parent


def ask_variables(opts: Namespace, variables: set[str]) -> dict[str, Any]:
    result = {k.upper(): v for k, v in opts.__dict__.items()}
    if ('LHOST' in variables or 'SRVURL' in variables) and not result.get('LHOST'):
        interfaces = list_interfaces()
        interface = fzf(interfaces, prompt='listener interface: ')
        addresses = list_ipv4_addresses(interface)
        result['LHOST'] = addresses[0]
    if 'LPORT' in variables and not result.get('LPORT'):
        result['LPORT'] = fzf(prompt='local port: ', query='1337')
    if 'RPORT' in variables and not result.get('RPORT'):
        result['RPORT'] = fzf(prompt='remote port: ', query='1337')
    if 'SRVURL' in variables and not result.get('SRVURL'):
        result['SRVURL'] = fzf(prompt='server url: ', query=f'http://{result["LHOST"]}/{random_string(5)}')
    return result


def list_interfaces() -> list[str]:
    return [interface['ifname'] for interface in ip('link', 'show')]


def list_ipv4_addresses(interface: str) -> list[str]:
    return [
        addr_info['local']
        for address in ip('address', 'show', interface)
        for addr_info in address['addr_info']
        if addr_info['family'] == 'inet'
    ]


def ip(*args: str) -> list[dict[str, Any]]:
    return json.loads(subprocess.check_output(['ip', '-json', *args], text=True))


def fzf(input: list[str]|None = None, prompt: str = '> ', query: str = '') -> str:
    output = subprocess.check_output(
        [
            'fzf',
            '--height', '50%',
            '--layout', 'reverse',
            '--prompt', prompt,
            '--query', query,
            '--bind', 'return:accept' if input else 'return:print-query',
            '--info', 'default' if input else 'hidden',
        ],
        input='\n'.join(input) if input else None,
        text=True,
    )
    return output.rstrip('\n')


def random_string(length: int) -> str:
    return ''.join(random.choice(string.ascii_lowercase) for _ in range(length))


def generic_encode(text: str|jinja2.environment.TemplateModule, encoding: str) -> bytes:
    if isinstance(text, str):
        return text.encode(encoding)
    elif isinstance(text, jinja2.environment.TemplateModule):
        return str(text).encode(encoding)
    else:
        raise TypeError()


def utf8_encode(text: str) -> bytes:
    return generic_encode(text, 'utf-8')


def utf16le_encode(text: str|jinja2.environment.TemplateModule) -> bytes:
    return generic_encode(text, 'utf-16le')


def base64_encode(data: bytes) -> str:
    assert isinstance(data, bytes)
    return base64.b64encode(data).decode('ascii')


def hex_encode(data: bytes) -> str:
    it = iter(data.hex())
    return ''.join('\\x' + c + next(it) for c in it)


def shell_quote(data: str) -> str:
    assert isinstance(data, str)
    return shlex.quote(data)


def build_jinja_env(loader: jinja2.BaseLoader) -> jinja2.Environment:
    env = jinja2.Environment(loader=loader, undefined=jinja2.StrictUndefined)
    env.filters['utf8'] = utf8_encode
    env.filters['utf16le'] = utf16le_encode
    env.filters['base64'] = base64_encode
    env.filters['hex'] = hex_encode
    env.filters['shellquote'] = shell_quote
    return env


def render_jinja(env: jinja2.Environment, text: str, variables: dict[str, str]) -> str:
    template = env.from_string(text)
    return template.render(**variables)


def grep_variables(env: jinja2.Environment, text: str) -> Generator[str, None, None]:
    assert env.loader
    ast = env.parse(text)
    yield from jinja2.meta.find_undeclared_variables(ast)
    for template_name in jinja2.meta.find_referenced_templates(ast):
        if template_name:
            text, *_ = env.loader.get_source(env, template_name)
            yield from grep_variables(env, text)


if __name__ == '__main__':
    main()
