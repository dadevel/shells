#!/usr/bin/env bash
set -eu

[[ -v XDG_RUNTIME_DIR ]] && declare -r temp="$XDG_RUNTIME_DIR/socat" || declare -r temp=/tmp

case "$#:$*" in
    2:listen\ *)
        tmux set-option -w -t "$TMUX_PANE" remain-on-exit on
        [[ -d "${temp}" ]] || mkdir "${temp}"
        # listen for incoming reverse shells
        exec socat -d -d tcp-listen:"$2",fork,reuseaddr exec:"${0@Q} handle"
        ;;
    1:handle)
        declare -r id="$(tmux new-window -n "$SOCAT_PEERADDR:$SOCAT_PEERPORT" -a -d -P -- "$0" connect "$SOCAT_PEERADDR" "$SOCAT_PEERPORT")"
        tmux display-message -d 2500 "connection received from $SOCAT_PEERADDR:$SOCAT_PEERPORT"
        # serve incoming connection over unix socket
        exec socat stdio unix-listen:"${temp}/$SOCAT_PEERADDR\\:$SOCAT_PEERPORT",fork,umask=0077
        ;;
    3:connect\ *)
        tmux set-option -w -t "$TMUX_PANE" remain-on-exit on
        for i in {0..9}; do
            [[ -S ""${temp}/$2:$3"" ]] && break || sleep 0.2
        done
        # setup connection between unix socket and tmux window
        exec socat unix:"${temp}/$2\\:$3" stdio
        ;;
    *)
        declare -i background=0
        declare -i port=7077
        declare session=''
        while getopts :bhp:s: OPTION; do
            case "$OPTION" in
                b)
                    background=1
                    ;;
                h)
                    echo "usage: $(basename "$0") [OPTIONS...]"
                    echo
                    echo 'options:'
                    echo '  -b         run in background, dont attach to the created tmux session'
                    echo '  -h         show this help message and exit'
                    echo '  -p PORT    override the socat listen port, default: 7077'
                    echo '  -s NAME    override the tmux session name, default: socat-$PORT'
                    exit 0
                    ;;
                p)
                    port="$OPTARG"
                    ;;
                s)
                    session="$OPTARG"
                    ;;
                *)
                    echo bad arguments >&2
                    exit 1
                    ;;
            esac
        done
        [[ -n "${session}" ]] || session="socat-${port}"
        tmux new-session -s "${session}" -n socat -d -- "$0" listen "${port}"
        (( background )) || exec tmux attach-session -t "${session}"
        ;;
esac

