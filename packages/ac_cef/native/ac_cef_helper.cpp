#include <windows.h>
#include <cstdio>
#include <cwchar>

typedef int (*ExecuteSubprocessFunc)(void);

int APIENTRY wWinMain(HINSTANCE hInstance, HINSTANCE, LPWSTR, int) {
    // Resolve the executable directory and add to DLL search path
    wchar_t exeDir[MAX_PATH];
    if (GetModuleFileNameW(nullptr, exeDir, MAX_PATH)) {
        wchar_t* lastSlash = wcsrchr(exeDir, L'\\');
        if (lastSlash) {
            *lastSlash = L'\0';
            SetDllDirectoryW(exeDir);
            
            wchar_t bridgePath[MAX_PATH];
            swprintf_s(bridgePath, MAX_PATH, L"%s\\ac_cef_bridge.dll", exeDir);
            
            HMODULE hBridge = LoadLibraryW(bridgePath);
            if (!hBridge) {
                hBridge = LoadLibraryW(L"ac_cef_bridge.dll");
            }

            if (hBridge) {
                ExecuteSubprocessFunc fn = (ExecuteSubprocessFunc)GetProcAddress(hBridge, "ac_cef_execute_subprocess");
                if (fn) {
                    int code = fn();
                    FreeLibrary(hBridge);
                    return code;
                }
                FreeLibrary(hBridge);
            }
        }
    }
    return 0;
}

