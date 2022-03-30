socat -dd file:$(tty),raw,echo=0 tcp-listen:§LPORT§,reuseaddr
