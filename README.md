# Shells

> A collection of reverse, bind and web shells from all over the internet.

Spotlight:

- [TCP reverse shell for multiple platforms with Cosmopolitan](./reverse/connector/cosmopolitan/)
- [TCP reverse shell for multiple architectures in Go](./reverse/connector/golang/)
- [Reverse shell listener with Tmux and Socat](./reverse/listener/tmux-socat-multiplexer/)
- [Python dropper utilizing `memfd_create()` on Linux](./dropper/memfd-create.py)
- [Python dropper that jumps to shellcode on Linux](./dropper/mmap-ctype.py)

## Usage

To interactively select and render one of the many templates run `./make.py`.

## Tips

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

### msfvenom

List available payload formats with `msfvenom --list formats`.

On Windows:

`windows/shell_reverse_tcp` is one of the few reverse shells that support interactive commands on Windows.
When your reverse shell terminates shortly after you receive the connection try setting `AutoRunScript=post/windows/manage/migrate` to run the reverse shell from a separate process.
