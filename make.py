#!/usr/bin/env python3
from typing import Any, Optional

import json
import os
import random
import re
import string
import subprocess

KNOWN_VARIABLES = {'LHOST', 'LPORT', 'RPORT', 'SRVURL'}


def main():
    files = list_files('.')
    path = fzf(files, prompt='template: ')
    with open(path) as file:
        content = file.read().rstrip('\n')
    variables = grep_variables(content)
    if unknown_variables := variables - KNOWN_VARIABLES:
        print(f'template {path} contains unknown variable: {", ".join(unknown_variables)}')
        exit(1)
    interfaces = list_interfaces()
    replacements = dict()
    if 'LHOST' in variables or 'SRVURL' in variables:
        interface = fzf(interfaces, prompt='listener interface: ')
        addresses = list_ipv4_addresses(interface)
        replacements['LHOST'] = addresses[0]
    if 'LPORT' in variables:
        replacements['LPORT'] = fzf(prompt='local port: ', query='7001')
    if 'RPORT' in variables:
        replacements['RPORT'] = fzf(prompt='remote port: ', query='1337')
    if 'SRVURL' in variables:
        replacements['SRVURL'] = fzf(prompt='server url: ', query=f'http://{replacements["LHOST"]}/{random_string(5)}')
    replacements = {f'§{key}§': value for key, value in replacements.items()}
    print(render_template(content, replacements))


def list_files(dir: str) -> list[str]:
    paths = (
        os.path.join(dirpath, filename).removeprefix('./')
        for dirpath, _, filenames in os.walk(dir)
        for filename in filenames
    )
    return [
        path for path in paths
        if not path.startswith('.') and not path.startswith('_') and path != 'README.md' and path != 'make.py'
    ]


def grep_variables(text: str) -> set[str]:
    return {match.group(1) for match in re.finditer(r'§([A-Z]+)§', text)}


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


def fzf(input: Optional[list[str]] = None, prompt: str = '> ', query: str = '') -> str:
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


def render_template(text: str, variables: dict[str, str]) -> str:
    replacements = {re.escape(k): v for k, v in variables.items()}
    pattern = re.compile('|'.join(replacements.keys()))
    return pattern.sub(lambda m: replacements[re.escape(m.group(0))] if m.group(0) else '', text)


if __name__ == '__main__':
    main()
