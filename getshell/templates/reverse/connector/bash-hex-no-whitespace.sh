{% import 'reverse/connector/bash-tcp.sh' as payload with context -%}
$'{{ payload|utf8|hex }}'
