socat -d -d openssl:{{ RHOST }}:{{ RPORT }},verify=0 stdout
