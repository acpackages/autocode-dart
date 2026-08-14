#include <windows.h>
#include <cstdio>
#include "include/cef_app.h"
#include "include/cef_client.h"

class TestApp : public CefApp, public CefBrowserProcessHandler {
public:
    CefRefPtr<CefBrowserProcessHandler> GetBrowserProcessHandler() override { return this; }
    void OnBeforeCommandLineProcessing(const CefString&, CefRefPtr<CefCommandLine> cmd) override {
        cmd->AppendSwitch("no-sandbox");
        cmd->AppendSwitch("disable-gpu");
        cmd->AppendSwitch("disable-gpu-compositing");
        cmd->AppendSwitch("disable-gpu-sandbox");
        cmd->AppendSwitch("disable-network-sandbox");
        cmd->AppendSwitch("disable-site-isolation-trials");
    }
    IMPLEMENT_REFCOUNTING(TestApp);
};

int main(int argc, char* argv[]) {
    printf("Starting test_cef_init...\n");
    CefMainArgs args(GetModuleHandle(NULL));
    CefRefPtr<TestApp> app = new TestApp();

    int ep = CefExecuteProcess(args, app.get(), nullptr);
    printf("CefExecuteProcess returned %d\n", ep);
    if (ep >= 0) return ep;

    CefSettings settings;
    settings.no_sandbox = 1;
    settings.windowless_rendering_enabled = 1;
    settings.multi_threaded_message_loop = 0;
    settings.command_line_args_disabled = 1;

    wchar_t exePath[MAX_PATH];
    GetModuleFileNameW(NULL, exePath, MAX_PATH);
    wchar_t* lastSlash = wcsrchr(exePath, L'\\');
    if (lastSlash) *lastSlash = L'\0';

    wchar_t cachePath[MAX_PATH];
    swprintf_s(cachePath, MAX_PATH, L"%s\\cef_cache_test", exePath);

    wchar_t helperPath[MAX_PATH];
    swprintf_s(helperPath, MAX_PATH, L"%s\\ac_cef_helper.exe", exePath);

    CefString(&settings.resources_dir_path) = exePath;
    CefString(&settings.locales_dir_path) = std::wstring(exePath) + L"\\locales";
    CefString(&settings.cache_path) = cachePath;
    CefString(&settings.root_cache_path) = cachePath;
    CefString(&settings.browser_subprocess_path) = helperPath;

    printf("Calling CefInitialize with helper: %ls, cache: %ls\n", helperPath, cachePath);
    bool ok = CefInitialize(args, settings, app.get(), nullptr);
    int exit_code = CefGetExitCode();
    printf("CefInitialize returned %s (exit_code: %d)\n", ok ? "TRUE" : "FALSE", exit_code);

    if (ok) {
        printf("CEF Initialized successfully with helper! Shutting down...\n");
        CefShutdown();
    }
    return 0;
}
