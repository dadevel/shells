socat -dd tcp-listen:{{ LPORT }},reuseaddr,fork stdout
