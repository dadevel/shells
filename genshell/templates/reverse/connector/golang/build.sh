#!/bin/sh
PS4='> '
set -eux

cd "$(dirname "$0")"
export CGO_ENABLED=0 "$@"
exec go build -o ./shell.bin -ldflags "-extldflags -static -s -w -X main.Target=${TARGET:?undefined variable}" ./shell.go
