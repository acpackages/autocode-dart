#include <windows.h>
#include "include/cef_app.h"

// Use WinMain to avoid opening a console window for subprocess processes.
int APIENTRY wWinMain(HINSTANCE hInstance, HINSTANCE, LPWSTR, int) {
    CefMainArgs main_args(hInstance);
    return CefExecuteProcess(main_args, nullptr, nullptr);
}
