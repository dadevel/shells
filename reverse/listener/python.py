#!/usr/bin/env python3
from telnetlib import Telnet
import socket

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
p = §LPORT§
s.bind(('', p))
s.listen(1)
print(f'*** Listening on :{p} ***')
try:
    while True:
        c, (a, p) = s.accept()
        print(f'*** Connection received from {a}:{p} ***')
        t = Telnet()
        t.sock = c
        t.interact()
except KeyboardInterrupt:
    pass
