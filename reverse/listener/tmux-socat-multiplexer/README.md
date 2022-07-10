# Port multiplexer with Tmux and Socat

A small bash script that listens for incoming reverse shell connections with `socat` and hands them of to `tmux`.
Based on scripts from [audibleblink/gorsh](https://github.com/audibleblink/gorsh/tree/master/scripts).

## Usage

Requirements:

- bash
- socat
- tmux

Just run `./tmux-listen.sh` to open a new tmux session with a reverse shell listener on port 7077/tcp.
Each incoming connection will create an additional tmux window.
