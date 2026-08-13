// ac_cef_bridge.cpp — complete implementation including OSR render handler
// See ac_cef_bridge.h for the public API.

#include "ac_cef_bridge.h"
#include "include/cef_app.h"
#include "include/cef_browser.h"
#include "include/cef_client.h"
#include "include/cef_command_line.h"
#include "include/cef_cookie.h"
#include "include/cef_render_handler.h"
#include "include/cef_request_context.h"
#include "include/wrapper/cef_helpers.h"
#include "include/wrapper/cef_message_router.h"
#include "include/cef_request_handler.h"
#include "include/cef_context_menu_handler.h"

#ifdef _WIN32
#  include <windows.h>
#  include <shellscalingapi.h>
#  include <cstdio>
#  pragma comment(lib, "Shcore.lib")
#endif

#include <map>
#include <mutex>
#include <string>

// ─── Global state ─────────────────────────────────────────────────────────────

static AcCefCallbacks g_callbacks = {};

struct BrowserInfo {
    CefRefPtr<CefBrowser> browser;
    int view_width  = 800;
    int view_height = 600;
    float dpr       = 1.0f;
    std::string title; // cached via OnTitleChange
};

static std::map<int64_t, BrowserInfo> g_browsers;
static std::mutex g_browsers_mutex;
static int64_t g_next_browser_id = 1;

static BrowserInfo* GetInfo(int64_t id) {
    auto it = g_browsers.find(id);
    return (it != g_browsers.end()) ? &it->second : nullptr;
}
static CefRefPtr<CefBrowser> GetBrowser(int64_t id) {
    auto* info = GetInfo(id);
    return info ? info->browser : nullptr;
}

// ─── Pending callbacks ────────────────────────────────────────────────────────

static std::map<int64_t, CefRefPtr<CefJSDialogCallback>>          g_js_cbs;
static std::map<int64_t, CefRefPtr<CefBeforeDownloadCallback>>    g_dl_cbs;
static std::map<int64_t, CefRefPtr<CefDownloadItemCallback>>      g_dl_item_cbs; // keyed by download_id
static std::map<int64_t, CefRefPtr<CefCallback>>                  g_cert_cbs;    // keyed by callback_id
static std::mutex g_cb_mutex;
static int64_t g_next_cb_id = 1;

static int64_t RegJS(CefRefPtr<CefJSDialogCallback> cb) {
    std::lock_guard<std::mutex> lk(g_cb_mutex);
    int64_t id = g_next_cb_id++;
    g_js_cbs[id] = cb;
    return id;
}
static int64_t RegDL(CefRefPtr<CefBeforeDownloadCallback> cb) {
    std::lock_guard<std::mutex> lk(g_cb_mutex);
    int64_t id = g_next_cb_id++;
    g_dl_cbs[id] = cb;
    return id;
}
static int64_t RegCert(CefRefPtr<CefCallback> cb) {
    std::lock_guard<std::mutex> lk(g_cb_mutex);
    int64_t id = g_next_cb_id++;
    g_cert_cbs[id] = cb;
    return id;
}

// ─── RenderHandler (OSR paint) ────────────────────────────────────────────────

class AcRenderHandler : public CefRenderHandler {
public:
    int64_t browser_id = 0;

    void GetViewRect(CefRefPtr<CefBrowser>, CefRect& rect) override {
        rect.x = rect.y = 0;
        std::lock_guard<std::mutex> lk(g_browsers_mutex);
        if (auto* info = GetInfo(browser_id)) {
            rect.width  = info->view_width;
            rect.height = info->view_height;
        } else {
            rect.width = 800; rect.height = 600;
        }
    }

    void OnPopupShow(CefRefPtr<CefBrowser>, bool show) override {
        if (g_callbacks.on_popup_show)
            g_callbacks.on_popup_show(browser_id, show ? 1 : 0);
    }
    void OnPopupSize(CefRefPtr<CefBrowser>, const CefRect& rect) override {
        if (g_callbacks.on_popup_size)
            g_callbacks.on_popup_size(browser_id, rect.x, rect.y, rect.width, rect.height);
    }
    void OnPaint(CefRefPtr<CefBrowser>, PaintElementType type,
                 const RectList& dirty, const void* buffer,
                 int width, int height) override {
        if (g_callbacks.on_paint) {
            // Pack dirty rects into a flat int array: x0,y0,w0,h0, x1,y1,...
            std::vector<int> flat;
            flat.reserve(dirty.size() * 4);
            for (const auto& r : dirty) {
                flat.push_back(r.x);
                flat.push_back(r.y);
                flat.push_back(r.width);
                flat.push_back(r.height);
            }
            g_callbacks.on_paint(browser_id,
                                 type == PET_POPUP ? 1 : 0,
                                 buffer, width, height,
                                 flat.empty() ? nullptr : flat.data(),
                                 (int)dirty.size());
        }
    }


    IMPLEMENT_REFCOUNTING(AcRenderHandler);
};

// ─── CefApp ───────────────────────────────────────────────────────────────────

class AcCefApp : public CefApp, public CefBrowserProcessHandler {
public:
    CefRefPtr<CefBrowserProcessHandler> GetBrowserProcessHandler() override { return this; }
    void OnBeforeCommandLineProcessing(const CefString&,
                                       CefRefPtr<CefCommandLine> cmd) override {
        cmd->AppendSwitch("no-sandbox");
        cmd->AppendSwitch("disable-gpu");
        cmd->AppendSwitch("disable-gpu-compositing");
        cmd->AppendSwitch("disable-gpu-sandbox");
        cmd->AppendSwitch("disable-network-sandbox");
        cmd->AppendSwitch("disable-software-rasterizer");
        cmd->AppendSwitch("enable-begin-frame-scheduling");
        // Force Alloy style for the entire process — prevents Chrome runtime
        // from opening a full browser window and triggering de-elevation.
        cmd->AppendSwitchWithValue("use-alloy-style", "1");
    }
    IMPLEMENT_REFCOUNTING(AcCefApp);
};

// ─── BrowserClient ────────────────────────────────────────────────────────────

class AcBrowserClient : public CefClient,
                         public CefLifeSpanHandler,
                         public CefLoadHandler,
                         public CefDisplayHandler,
                         public CefFocusHandler,
                         public CefKeyboardHandler,
                         public CefJSDialogHandler,
                         public CefDownloadHandler,
                         public CefRequestHandler,
                         public CefContextMenuHandler {
 public:
     int64_t browser_id = 0;
     CefRefPtr<AcRenderHandler> render_handler;
     CefRefPtr<CefMessageRouterBrowserSide> messenger;

     AcBrowserClient() : render_handler(new AcRenderHandler()) {}

     CefRefPtr<CefRenderHandler>   GetRenderHandler()   override { return render_handler; }
     CefRefPtr<CefLifeSpanHandler> GetLifeSpanHandler() override { return this; }
     CefRefPtr<CefLoadHandler>     GetLoadHandler()     override { return this; }
     CefRefPtr<CefDisplayHandler>  GetDisplayHandler()  override { return this; }
     CefRefPtr<CefFocusHandler>    GetFocusHandler()    override { return this; }
     CefRefPtr<CefKeyboardHandler> GetKeyboardHandler() override { return this; }
     CefRefPtr<CefJSDialogHandler> GetJSDialogHandler() override { return this; }
     CefRefPtr<CefDownloadHandler> GetDownloadHandler() override { return this; }
     CefRefPtr<CefRequestHandler>  GetRequestHandler()  override { return this; }
     CefRefPtr<CefContextMenuHandler> GetContextMenuHandler() override { return this; }

    // ── LifeSpan ──────────────────────────────────────────────────────────────
    void OnAfterCreated(CefRefPtr<CefBrowser> browser) override {
        std::lock_guard<std::mutex> lk(g_browsers_mutex);
        browser_id = g_next_browser_id++;
        render_handler->browser_id = browser_id;
        g_browsers[browser_id].browser = browser;
        if (g_callbacks.on_after_created)
            g_callbacks.on_after_created(browser_id);
    }
    bool DoClose(CefRefPtr<CefBrowser> browser) override { return false; }
    void OnBeforeClose(CefRefPtr<CefBrowser> browser) override {
        if (messenger) {
            messenger->OnBeforeClose(browser);
        }
        if (g_callbacks.on_before_close)
            g_callbacks.on_before_close(browser_id);
        std::lock_guard<std::mutex> lk(g_browsers_mutex);
        g_browsers.erase(browser_id);
    }
    void OnRenderProcessTerminated(CefRefPtr<CefBrowser> browser, TerminationStatus status, int error_code, const CefString& error_string) override {
        if (messenger) {
            messenger->OnRenderProcessTerminated(browser);
        }
        if (g_callbacks.on_render_process_terminated)
            g_callbacks.on_render_process_terminated(
                browser_id, (int)status, error_code,
                error_string.ToString().c_str());
    }
    bool OnBeforePopup(CefRefPtr<CefBrowser> browser,
                       CefRefPtr<CefFrame> frame,
                       int popup_id,
                       const CefString& target_url,
                       const CefString& target_frame_name,
                       cef_window_open_disposition_t target_disposition,
                       bool user_gesture,
                       const CefPopupFeatures& popupFeatures,
                       CefWindowInfo& windowInfo,
                       CefRefPtr<CefClient>& client,
                       CefBrowserSettings& settings,
                       CefRefPtr<CefDictionaryValue>& extra_info,
                       bool* no_javascript_access) override {
        if (g_callbacks.on_before_popup) {
            int cancel = g_callbacks.on_before_popup(browser_id,
                target_url.ToString().c_str(),
                target_frame_name.ToString().c_str(),
                (int)target_disposition,
                user_gesture ? 1 : 0);
            if (cancel) return true;  // Dart handler said cancel
        }
        // Allow popup as an OSR browser so it integrates with the same
        // paint pipeline. A fresh AcBrowserClient receives OnAfterCreated
        // with the popup's browser_id, which Dart can wrap in a new CefView.
        windowInfo.SetAsWindowless(0);   // 0 = opaque background
        client = new AcBrowserClient();  // ID assigned in OnAfterCreated
        return false;                    // allow popup creation
    }

    // ── LoadHandler ───────────────────────────────────────────────────────────
    void OnLoadingStateChange(CefRefPtr<CefBrowser> browser,
                              bool isLoading, bool canGoBack, bool canGoForward) override {
        if (g_callbacks.on_loading_state_changed)
            g_callbacks.on_loading_state_changed(browser_id, isLoading, canGoBack, canGoForward);
    }
    void OnLoadStart(CefRefPtr<CefBrowser> browser, CefRefPtr<CefFrame> f,
                     TransitionType t) override {
        if (g_callbacks.on_load_start)
            g_callbacks.on_load_start(browser_id, f->GetURL().ToString().c_str(), (int)t);
    }
    void OnLoadEnd(CefRefPtr<CefBrowser> browser, CefRefPtr<CefFrame> f,
                   int http_status_code) override {
        if (g_callbacks.on_load_end)
            g_callbacks.on_load_end(browser_id, f->GetURL().ToString().c_str(), http_status_code);
    }
    void OnLoadError(CefRefPtr<CefBrowser> browser, CefRefPtr<CefFrame> f,
                     ErrorCode code, const CefString& text,
                     const CefString& url) override {
        if (g_callbacks.on_load_error)
            g_callbacks.on_load_error(browser_id, f->GetURL().ToString().c_str(), (int)code,
                                      text.ToString().c_str(), url.ToString().c_str());
    }

    // ── DisplayHandler ────────────────────────────────────────────────────────
    void OnAddressChange(CefRefPtr<CefBrowser>, CefRefPtr<CefFrame>,
                         const CefString& url) override {
        if (g_callbacks.on_url_changed)
            g_callbacks.on_url_changed(browser_id, url.ToString().c_str());
    }
    void OnTitleChange(CefRefPtr<CefBrowser>, const CefString& t) override {
        // Cache the title so ac_cef_get_title can return it synchronously.
        {
            std::lock_guard<std::mutex> lk(g_browsers_mutex);
            if (auto* info = GetInfo(browser_id))
                info->title = t.ToString();
        }
        if (g_callbacks.on_title_changed)
            g_callbacks.on_title_changed(browser_id, t.ToString().c_str());
    }
    bool OnCursorChange(CefRefPtr<CefBrowser> browser,
                        CefCursorHandle cursor,
                        cef_cursor_type_t type,
                        const CefCursorInfo& custom_cursor_info) override {
        if (g_callbacks.on_cursor_changed)
            g_callbacks.on_cursor_changed(browser_id, (int)type);
        return false;
    }
    void OnStatusMessage(CefRefPtr<CefBrowser>, const CefString& value) override {
        if (g_callbacks.on_status_message)
            g_callbacks.on_status_message(browser_id, value.ToString().c_str());
    }
    bool OnTooltip(CefRefPtr<CefBrowser>, CefString& text) override {
        if (g_callbacks.on_tooltip)
            return g_callbacks.on_tooltip(browser_id, text.ToString().c_str()) != 0;
        return false;
    }
    bool OnConsoleMessage(CefRefPtr<CefBrowser>, cef_log_severity_t level,
                          const CefString& msg, const CefString& src, int line) override {
        if (g_callbacks.on_console_message)
            return g_callbacks.on_console_message(browser_id, (int)level,
                msg.ToString().c_str(), src.ToString().c_str(), line) != 0;
        return false;
    }

    // ── FocusHandler ──────────────────────────────────────────────────────────
    void OnGotFocus(CefRefPtr<CefBrowser>) override {
        if (g_callbacks.on_got_focus)
            g_callbacks.on_got_focus(browser_id);
    }

    // ── DisplayHandler (additional) ───────────────────────────────────────────
    void OnFullscreenModeChange(CefRefPtr<CefBrowser>, bool fullscreen) override {
        if (g_callbacks.on_fullscreen_mode_change)
            g_callbacks.on_fullscreen_mode_change(browser_id, fullscreen ? 1 : 0);
    }

    // ── KeyboardHandler ───────────────────────────────────────────────────────
    bool OnPreKeyEvent(CefRefPtr<CefBrowser>, const CefKeyEvent& event,
                       CefEventHandle /*os_event*/, bool* is_keyboard_shortcut) override {
        if (g_callbacks.on_pre_key_event) {
            int shortcut_out = 0;
            int r = g_callbacks.on_pre_key_event(
                browser_id, (int)event.type,
                event.windows_key_code, event.native_key_code, event.modifiers,
                (int)event.character, (int)event.unmodified_character,
                event.is_system_key ? 1 : 0, &shortcut_out);
            if (is_keyboard_shortcut) *is_keyboard_shortcut = (shortcut_out != 0);
            return r != 0;
        }
        return false;
    }
    bool OnKeyEvent(CefRefPtr<CefBrowser>, const CefKeyEvent& event,
                    CefEventHandle /*os_event*/) override {
        if (g_callbacks.on_key_event) {
            return g_callbacks.on_key_event(
                browser_id, (int)event.type,
                event.windows_key_code, event.native_key_code, event.modifiers,
                (int)event.character, (int)event.unmodified_character,
                event.is_system_key ? 1 : 0) != 0;
        }
        return false;
    }

    // ── JSDialogHandler ───────────────────────────────────────────────────────
    bool OnJSDialog(CefRefPtr<CefBrowser>, const CefString& origin,
                    JSDialogType type, const CefString& msg,
                    const CefString& prompt,
                    CefRefPtr<CefJSDialogCallback> cb, bool& suppress) override {
        if (g_callbacks.on_js_dialog) {
            int64_t id = RegJS(cb);
            return g_callbacks.on_js_dialog(browser_id, origin.ToString().c_str(),
                (int)type, msg.ToString().c_str(), prompt.ToString().c_str(), id) != 0;
        }
        return false;
    }
    bool OnBeforeUnloadDialog(CefRefPtr<CefBrowser>, const CefString& msg,
                              bool is_reload, CefRefPtr<CefJSDialogCallback> cb) override {
        if (g_callbacks.on_before_unload_dialog) {
            int64_t id = RegJS(cb);
            return g_callbacks.on_before_unload_dialog(
                browser_id, msg.ToString().c_str(), is_reload ? 1 : 0, id) != 0;
        }
        // Default: auto-accept (continue navigation)
        cb->Continue(true, CefString());
        return true;
    }

    // ── DownloadHandler ───────────────────────────────────────────────────────
    bool OnBeforeDownload(CefRefPtr<CefBrowser>, CefRefPtr<CefDownloadItem> item,
                          const CefString& suggested,
                          CefRefPtr<CefBeforeDownloadCallback> cb) override {
        if (g_callbacks.on_before_download) {
            int64_t id = RegDL(cb);
            return g_callbacks.on_before_download(browser_id, item->GetId(),
                item->GetURL().ToString().c_str(),
                suggested.ToString().c_str(), id) != 0;
        }
        return false;
    }
    void OnDownloadUpdated(CefRefPtr<CefBrowser>, CefRefPtr<CefDownloadItem> item,
                           CefRefPtr<CefDownloadItemCallback> cb) override {
        // Store the callback so Dart can call Cancel() later via ac_cef_cancel_download
        {
            std::lock_guard<std::mutex> lk(g_cb_mutex);
            g_dl_item_cbs[item->GetId()] = cb;
        }
        if (g_callbacks.on_download_updated)
            g_callbacks.on_download_updated(browser_id, item->GetId(),
                item->GetPercentComplete(), item->IsComplete(), item->IsCanceled());
        // Clean up when download is finished
        if (item->IsComplete() || item->IsCanceled()) {
            std::lock_guard<std::mutex> lk(g_cb_mutex);
            g_dl_item_cbs.erase(item->GetId());
        }
    }

    // ── ContextMenuHandler ──────────────────────────────────────────────────
    void OnBeforeContextMenu(CefRefPtr<CefBrowser> browser,
                             CefRefPtr<CefFrame> frame,
                             CefRefPtr<CefContextMenuParams> params,
                             CefRefPtr<CefMenuModel> model) override {
        if (g_callbacks.on_before_context_menu) {
            // ── Menu items ────────────────────────────────────────────────
            int count = model->GetCount();
            std::vector<int>         cmd_ids(count);
            std::vector<int>         types(count);
            std::vector<int>         enabled(count);
            std::vector<int>         checked(count);
            std::vector<std::string> label_strs(count);
            std::vector<const char*> labels(count);
            for (int i = 0; i < count; ++i) {
                cmd_ids[i]    = model->GetCommandIdAt(i);
                types[i]      = (int)model->GetTypeAt(i);
                enabled[i]    = model->IsEnabledAt(i) ? 1 : 0;
                checked[i]    = model->IsCheckedAt(i) ? 1 : 0;
                label_strs[i] = model->GetLabelAt(i).ToString();
                labels[i]     = label_strs[i].c_str();
            }
            // ── CefContextMenuParams ──────────────────────────────────────
            std::string link_url      = params->GetLinkUrl().ToString();
            std::string page_url      = params->GetPageUrl().ToString();
            std::string frame_url     = params->GetFrameUrl().ToString();
            std::string source_url    = params->GetSourceUrl().ToString();
            std::string sel_text      = params->GetSelectionText().ToString();
            std::string misspelled    = params->GetMisspelledWord().ToString();
            g_callbacks.on_before_context_menu(
                browser_id,
                params->GetXCoord(), params->GetYCoord(),
                count,
                count > 0 ? cmd_ids.data()  : nullptr,
                count > 0 ? labels.data()   : nullptr,
                count > 0 ? types.data()    : nullptr,
                count > 0 ? enabled.data()  : nullptr,
                count > 0 ? checked.data()  : nullptr,
                link_url.c_str(),
                page_url.c_str(),
                frame_url.c_str(),
                source_url.c_str(),
                sel_text.c_str(),
                misspelled.c_str(),
                (int)params->GetMediaType(),
                params->GetTypeFlags(),
                params->GetMediaStateFlags(),
                params->GetEditStateFlags(),
                params->IsEditable() ? 1 : 0,
                params->HasImageContents() ? 1 : 0);
        }
        // Always clear — Dart shows a custom Flutter overlay instead.
        model->Clear();
    }

    // ── RequestHandler ────────────────────────────────────────────────────────
    bool OnBeforeBrowse(CefRefPtr<CefBrowser> browser, CefRefPtr<CefFrame> frame,
                        CefRefPtr<CefRequest> request, bool user_gesture,
                        bool is_redirect) override {
        if (messenger) {
            messenger->OnBeforeBrowse(browser, frame);
        }
        if (g_callbacks.on_before_browse) {
            return g_callbacks.on_before_browse(browser_id,
                request->GetURL().ToString().c_str(), is_redirect != 0) != 0;
        }
        return false;
    }
    bool OnCertificateError(CefRefPtr<CefBrowser>, cef_errorcode_t cert_error,
                            const CefString& request_url,
                            CefRefPtr<CefSSLInfo> /*ssl_info*/,
                            CefRefPtr<CefCallback> cb) override {
        if (g_callbacks.on_certificate_error) {
            int64_t id = RegCert(cb);
            return g_callbacks.on_certificate_error(
                browser_id, (int)cert_error,
                request_url.ToString().c_str(), id) != 0;
        }
        return false;  // default: cancel (certificate error blocks navigation)
    }


    // ── MessageRouter ────────────────────────────────────────────────────────
    bool OnProcessMessageReceived(CefRefPtr<CefBrowser> browser,
                                  CefRefPtr<CefFrame> frame,
                                  CefProcessId source_process,
                                  CefRefPtr<CefProcessMessage> message) override {
        if (messenger && messenger->OnProcessMessageReceived(browser, frame, source_process, message)) {
            return true;
        }
        return false;
    }

    IMPLEMENT_REFCOUNTING(AcBrowserClient);
};

// ─── C exports ────────────────────────────────────────────────────────────────

extern "C" {

AC_CEF_EXPORT int ac_cef_initialize(
    const char** keys, const char** values, int count,
    const AcCefCallbacks* cbs)
{
    printf("[ac_cef_bridge] ac_cef_initialize called. PID=%lu\n", GetCurrentProcessId());
    fflush(stdout);

    // Check if we are elevated
    BOOL isElevated = FALSE;
    HANDLE hToken = NULL;
    if (OpenProcessToken(GetCurrentProcess(), TOKEN_QUERY, &hToken)) {
        TOKEN_ELEVATION elevation;
        DWORD dwSize;
        if (GetTokenInformation(hToken, TokenElevation, &elevation, sizeof(elevation), &dwSize)) {
            isElevated = elevation.TokenIsElevated;
        }
        CloseHandle(hToken);
    }
    printf("[ac_cef_bridge] Process elevated: %s\n", isElevated ? "YES" : "NO");
    fflush(stdout);

    if (cbs) g_callbacks = *cbs;

#ifdef _WIN32
    SetProcessDpiAwarenessContext(DPI_AWARENESS_CONTEXT_PER_MONITOR_AWARE_V2);
    CefMainArgs args(GetModuleHandleW(nullptr));
#else
    CefMainArgs args;
#endif

    CefSettings settings;
    settings.windowless_rendering_enabled = true;
    settings.no_sandbox = true;
    settings.multi_threaded_message_loop = false;
    settings.external_message_pump = false;

    // Apply Dart-supplied key/value settings
    for (int i = 0; i < count; ++i) {
        std::string k(keys[i]), v(values[i]);
        printf("[ac_cef_bridge] Setting: %s = %s\n", k.c_str(), v.c_str());
        if      (k == "cache_path")            CefString(&settings.cache_path) = v;
        else if (k == "user_agent")            CefString(&settings.user_agent) = v;
        else if (k == "locale")                CefString(&settings.locale) = v;
        else if (k == "log_file")              CefString(&settings.log_file) = v;
        else if (k == "resources_dir_path")    CefString(&settings.resources_dir_path) = v;
        else if (k == "locales_dir_path")      CefString(&settings.locales_dir_path) = v;
        else if (k == "browser_subprocess_path")
            CefString(&settings.browser_subprocess_path) = v;
        else if (k == "remote_debugging_port")
            settings.remote_debugging_port = std::stoi(v);
        else if (k == "no_sandbox")
            settings.no_sandbox = (v == "true");
        else if (k == "log_severity") {
            if      (v == "verbose") settings.log_severity = LOGSEVERITY_VERBOSE;
            else if (v == "info")    settings.log_severity = LOGSEVERITY_INFO;
            else if (v == "warning") settings.log_severity = LOGSEVERITY_WARNING;
            else if (v == "error")   settings.log_severity = LOGSEVERITY_ERROR;
            else if (v == "fatal")   settings.log_severity = LOGSEVERITY_FATAL;
            else if (v == "disable") settings.log_severity = LOGSEVERITY_DISABLE;
        }
    }
    fflush(stdout);

    printf("[ac_cef_bridge] Final settings: no_sandbox=%d, windowless=%d, multi_threaded=%d\n",
           settings.no_sandbox, settings.windowless_rendering_enabled, settings.multi_threaded_message_loop);
    fflush(stdout);

    CefRefPtr<AcCefApp> app = new AcCefApp();

    printf("[ac_cef_bridge] Calling CefExecuteProcess...\n");
    fflush(stdout);
    int ep = CefExecuteProcess(args, app.get(), nullptr);
    printf("[ac_cef_bridge] CefExecuteProcess returned %d\n", ep);
    fflush(stdout);
    if (ep >= 0) {
        return -(ep + 1);
    }

    printf("[ac_cef_bridge] Calling CefInitialize...\n");
    fflush(stdout);
    bool success = CefInitialize(args, settings, app.get(), nullptr);
    printf("[ac_cef_bridge] CefInitialize returned %s\n", success ? "TRUE" : "FALSE");
    fflush(stdout);

    return 1;
}

AC_CEF_EXPORT void ac_cef_shutdown()          { CefShutdown(); }
AC_CEF_EXPORT void ac_cef_do_message_loop_work() { CefDoMessageLoopWork(); }
AC_CEF_EXPORT void ac_cef_run_message_loop()  { CefRunMessageLoop(); }
AC_CEF_EXPORT void ac_cef_quit_message_loop() { CefQuitMessageLoop(); }

AC_CEF_EXPORT int64_t ac_cef_create_browser(const char* url, int fps, int transp) {
    CefRefPtr<AcBrowserClient> client = new AcBrowserClient();
    CefWindowInfo wi;
    wi.SetAsWindowless(0);
    // CEF 146+ defaults to Chrome runtime which opens a full browser window.
    // Alloy runtime is required for off-screen rendering (OSR).
    wi.runtime_style = CEF_RUNTIME_STYLE_ALLOY;
    CefBrowserSettings bs;
    bs.windowless_frame_rate = fps > 0 ? fps : 30;
    CefBrowserHost::CreateBrowser(wi, client, url, bs, nullptr, nullptr);
    // browser_id assigned asynchronously in OnAfterCreated
    return 0;
}

AC_CEF_EXPORT void ac_cef_set_view_size(int64_t id, int w, int h, float dpr) {
    std::lock_guard<std::mutex> lk(g_browsers_mutex);
    if (auto* info = GetInfo(id)) {
        info->view_width  = w;
        info->view_height = h;
        info->dpr         = dpr;
    }
}

AC_CEF_EXPORT void ac_cef_load_url(int64_t id, const char* url)
    { if (auto b = GetBrowser(id)) b->GetMainFrame()->LoadURL(url); }
AC_CEF_EXPORT void ac_cef_go_back(int64_t id)
    { if (auto b = GetBrowser(id)) b->GoBack(); }
AC_CEF_EXPORT void ac_cef_go_forward(int64_t id)
    { if (auto b = GetBrowser(id)) b->GoForward(); }
AC_CEF_EXPORT void ac_cef_reload(int64_t id)
    { if (auto b = GetBrowser(id)) b->Reload(); }
AC_CEF_EXPORT void ac_cef_stop_load(int64_t id)
    { if (auto b = GetBrowser(id)) b->StopLoad(); }
AC_CEF_EXPORT void ac_cef_close_browser(int64_t id, int force)
    { if (auto b = GetBrowser(id)) b->GetHost()->CloseBrowser(force != 0); }
AC_CEF_EXPORT void ac_cef_execute_javascript(int64_t id, const char* code)
    { if (auto b = GetBrowser(id)) b->GetMainFrame()->ExecuteJavaScript(code, "", 0); }
AC_CEF_EXPORT void ac_cef_set_zoom_level(int64_t id, double lvl)
    { if (auto b = GetBrowser(id)) b->GetHost()->SetZoomLevel(lvl); }
AC_CEF_EXPORT double ac_cef_get_zoom_level(int64_t id) {
    if (auto b = GetBrowser(id)) return b->GetHost()->GetZoomLevel();
    return 0.0;
}
AC_CEF_EXPORT void ac_cef_was_resized(int64_t id)
    { if (auto b = GetBrowser(id)) b->GetHost()->WasResized(); }
AC_CEF_EXPORT void ac_cef_was_hidden(int64_t id, int hidden)
    { if (auto b = GetBrowser(id)) b->GetHost()->WasHidden(hidden != 0); }
AC_CEF_EXPORT void ac_cef_invalidate(int64_t id)
    { if (auto b = GetBrowser(id)) b->GetHost()->Invalidate(PET_VIEW); }
AC_CEF_EXPORT void ac_cef_set_focus(int64_t id, int focus)
    { if (auto b = GetBrowser(id)) b->GetHost()->SetFocus(focus != 0); }

AC_CEF_EXPORT void ac_cef_send_mouse_move(int64_t id, int x, int y, int mods, int leave) {
    if (auto b = GetBrowser(id)) {
        CefMouseEvent ev; ev.x = x; ev.y = y; ev.modifiers = mods;
        b->GetHost()->SendMouseMoveEvent(ev, leave != 0);
    }
}
AC_CEF_EXPORT void ac_cef_send_mouse_click(int64_t id, int x, int y,
    int btn, int up, int count, int mods) {
    if (auto b = GetBrowser(id)) {
        CefMouseEvent ev; ev.x = x; ev.y = y; ev.modifiers = mods;
        auto t = btn == 1 ? MBT_RIGHT : btn == 2 ? MBT_MIDDLE : MBT_LEFT;
        b->GetHost()->SendMouseClickEvent(ev, t, up != 0, count);
        if (!up) b->GetHost()->SetFocus(true);
    }
}
AC_CEF_EXPORT void ac_cef_send_mouse_wheel(int64_t id, int x, int y, int dx, int dy) {
    if (auto b = GetBrowser(id)) {
        CefMouseEvent ev; ev.x = x; ev.y = y;
        b->GetHost()->SendMouseWheelEvent(ev, dx, dy);
    }
}
AC_CEF_EXPORT void ac_cef_send_key_event(int64_t id, int type, int wk, int nk,
    int mods, int ch, int uch, int sys) {
    if (auto b = GetBrowser(id)) {
        CefKeyEvent ev;
        ev.type = (cef_key_event_type_t)type;
        ev.windows_key_code = wk;
        ev.native_key_code = nk;
        ev.modifiers = mods;
        ev.character = (char16_t)ch;
        ev.unmodified_character = (char16_t)uch;
        ev.is_system_key = sys != 0;
        ev.focus_on_editable_field = 1;
        b->GetHost()->SendKeyEvent(ev);
    }
}

AC_CEF_EXPORT void ac_cef_ime_commit_text(int64_t id, const char* text) {
    if (auto b = GetBrowser(id)) {
        CefString cef_text(text);
        CefRange range(UINT32_MAX, UINT32_MAX); // Replace selection or insert at cursor
        b->GetHost()->ImeCommitText(cef_text, range, 0);
    }
}

AC_CEF_EXPORT void ac_cef_ime_set_composition(
    int64_t id, const char* text, int cursor_pos,
    int selection_start, int selection_end) {
    if (auto b = GetBrowser(id)) {
        CefString cef_text(text ? text : "");
        // No underline styling — pass empty vector.
        std::vector<CefCompositionUnderline> underlines;
        // cursor_pos: -1 means end of text
        int len = (int)cef_text.size();
        int cursor = (cursor_pos < 0) ? len : cursor_pos;
        CefRange sel;
        if (selection_start < 0 || selection_end < 0) {
            sel = CefRange(cursor, cursor);
        } else {
            sel = CefRange(selection_start, selection_end);
        }
        b->GetHost()->ImeSetComposition(cef_text, underlines, CefRange(UINT32_MAX, UINT32_MAX), sel);
    }
}

AC_CEF_EXPORT void ac_cef_ime_cancel_composition(int64_t id) {
    if (auto b = GetBrowser(id))
        b->GetHost()->ImeCancelComposition();
}
AC_CEF_EXPORT void ac_cef_js_dialog_response(int64_t cb_id, int ok, const char* input) {
    std::lock_guard<std::mutex> lk(g_cb_mutex);
    auto it = g_js_cbs.find(cb_id);
    if (it != g_js_cbs.end()) {
        it->second->Continue(ok != 0, input ? input : "");
        g_js_cbs.erase(it);
    }
}

// ─── Message router implementation ────────────────────────────────────────────

class AcQueryHandler : public CefMessageRouterBrowserSide::Handler {
public:
    int64_t browser_id;
    OnQueryCallback on_query;
    OnQueryCanceledCallback on_canceled;

    AcQueryHandler(int64_t b_id, OnQueryCallback q, OnQueryCanceledCallback c)
        : browser_id(b_id), on_query(q), on_canceled(c) {}

    static std::map<int64_t, CefRefPtr<CefMessageRouterBrowserSide::Callback>> g_query_cbs;
    static std::mutex g_cb_mutex;

    bool OnQuery(CefRefPtr<CefBrowser> browser,
                 CefRefPtr<CefFrame> frame,
                 int64_t query_id,
                 const CefString& request,
                 bool persistent,
                 CefRefPtr<Callback> callback) override {
        if (on_query) {
            {
                std::lock_guard<std::mutex> lk(g_cb_mutex);
                g_query_cbs[query_id] = callback;
            }
            on_query(browser_id, query_id, request.ToString().c_str(), persistent ? 1 : 0);
            return true;
        }
        return false;
    }

    void OnQueryCanceled(CefRefPtr<CefBrowser> browser,
                         CefRefPtr<CefFrame> frame,
                         int64_t query_id) override {
        {
            std::lock_guard<std::mutex> lk(g_cb_mutex);
            g_query_cbs.erase(query_id);
        }
        if (on_canceled) {
            on_canceled(browser_id, query_id);
        }
    }
};

std::map<int64_t, CefRefPtr<CefMessageRouterBrowserSide::Callback>> AcQueryHandler::g_query_cbs;
std::mutex AcQueryHandler::g_cb_mutex;

AC_CEF_EXPORT void ac_cef_message_router_create(
    int64_t browser_id,
    const char* js_query_fn,
    const char* js_cancel_fn,
    OnQueryCallback on_query,
    OnQueryCanceledCallback on_query_canceled) {
    
    std::lock_guard<std::mutex> lk(g_browsers_mutex);
    auto b = GetBrowser(browser_id);
    if (!b) return;

    CefRefPtr<AcBrowserClient> client = (AcBrowserClient*)b->GetHost()->GetClient().get();
    
    CefMessageRouterConfig config;
    config.js_query_function = js_query_fn;
    config.js_cancel_function = js_cancel_fn;

    client->messenger = CefMessageRouterBrowserSide::Create(config);
    client->messenger->AddHandler(new AcQueryHandler(browser_id, on_query, on_query_canceled), true);
}

AC_CEF_EXPORT void ac_cef_query_response(int64_t browser_id, int64_t query_id, const char* response) {
    std::lock_guard<std::mutex> lk(AcQueryHandler::g_cb_mutex);
    auto it = AcQueryHandler::g_query_cbs.find(query_id);
    if (it != AcQueryHandler::g_query_cbs.end()) {
        it->second->Success(response ? response : "");
        AcQueryHandler::g_query_cbs.erase(it);
    }
}

AC_CEF_EXPORT void ac_cef_query_failure(int64_t browser_id, int64_t query_id, int error_code, const char* error_message) {
    std::lock_guard<std::mutex> lk(AcQueryHandler::g_cb_mutex);
    auto it = AcQueryHandler::g_query_cbs.find(query_id);
    if (it != AcQueryHandler::g_query_cbs.end()) {
        it->second->Failure(error_code, error_message ? error_message : "");
        AcQueryHandler::g_query_cbs.erase(it);
    }
}
AC_CEF_EXPORT void ac_cef_before_download_response(int64_t cb_id, const char* path, int show) {
    std::lock_guard<std::mutex> lk(g_cb_mutex);
    auto it = g_dl_cbs.find(cb_id);
    if (it != g_dl_cbs.end()) {
        it->second->Continue(path ? path : "", show != 0);
        g_dl_cbs.erase(it);
    }
}
AC_CEF_EXPORT void ac_cef_cancel_download(int64_t /*browser_id*/, int64_t download_id) {
    std::lock_guard<std::mutex> lk(g_cb_mutex);
    auto it = g_dl_item_cbs.find(download_id);
    if (it != g_dl_item_cbs.end()) {
        it->second->Cancel();
        g_dl_item_cbs.erase(it);
    }
}

AC_CEF_EXPORT void ac_cef_pause_download(int64_t /*browser_id*/, int64_t download_id) {
    std::lock_guard<std::mutex> lk(g_cb_mutex);
    auto it = g_dl_item_cbs.find(download_id);
    if (it != g_dl_item_cbs.end())
        it->second->Pause();
}

AC_CEF_EXPORT void ac_cef_resume_download(int64_t /*browser_id*/, int64_t download_id) {
    std::lock_guard<std::mutex> lk(g_cb_mutex);
    auto it = g_dl_item_cbs.find(download_id);
    if (it != g_dl_item_cbs.end())
        it->second->Resume();
}

AC_CEF_EXPORT void ac_cef_certificate_error_response(int64_t callback_id, int allow) {
    std::lock_guard<std::mutex> lk(g_cb_mutex);
    auto it = g_cert_cbs.find(callback_id);
    if (it != g_cert_cbs.end()) {
        if (allow) it->second->Continue();
        else       it->second->Cancel();
        g_cert_cbs.erase(it);
    }
}

AC_CEF_EXPORT void ac_cef_clear_all_cookies() {
    CefCookieManager::GetGlobalManager(nullptr)->DeleteCookies("", "", nullptr);
}
AC_CEF_EXPORT void ac_cef_set_cookie(const char* url, const char* name,
    const char* value, const char* domain, const char* path,
    int secure, int http_only, int64_t /*expires*/) {
    CefCookie c;
    CefString(&c.name)   = name;
    CefString(&c.value)  = value;
    CefString(&c.domain) = domain;
    CefString(&c.path)   = path;
    c.secure = secure != 0; c.httponly = http_only != 0;
    CefCookieManager::GetGlobalManager(nullptr)->SetCookie(url, c, nullptr);
}

// ─── Message router ──────────────────────────────────────────────────────────
// (Implementation moved above)

// ─── DevTools ─────────────────────────────────────────────────────────────────

AC_CEF_EXPORT void ac_cef_open_dev_tools(int64_t id) {
    if (auto b = GetBrowser(id)) {
        CefWindowInfo wi;
#ifdef _WIN32
        wi.SetAsPopup(nullptr, "DevTools");
#endif
        CefBrowserSettings bs;
        b->GetHost()->ShowDevTools(wi, nullptr, bs, CefPoint());
    }
}

AC_CEF_EXPORT void ac_cef_close_dev_tools(int64_t id) {
    if (auto b = GetBrowser(id))
        b->GetHost()->CloseDevTools();
}

// ─── Print to PDF ─────────────────────────────────────────────────────────────

class PdfPrintCallback : public CefPdfPrintCallback {
public:
    int64_t browser_id;
    std::string path;
    OnPrintToPdfCallback dart_cb;

    PdfPrintCallback(int64_t bid, const std::string& p, OnPrintToPdfCallback cb)
        : browser_id(bid), path(p), dart_cb(cb) {}

    void OnPdfPrintFinished(const CefString& /*path*/, bool ok) override {
        if (dart_cb)
            dart_cb(browser_id, path.c_str(), ok ? 1 : 0);
    }
    IMPLEMENT_REFCOUNTING(PdfPrintCallback);
};

AC_CEF_EXPORT void ac_cef_print_to_pdf(
    int64_t id, const char* path, OnPrintToPdfCallback callback)
{
    if (auto b = GetBrowser(id)) {
        CefPdfPrintSettings ps;
        // Default A4, landscape=false
        CefRefPtr<PdfPrintCallback> cb =
            new PdfPrintCallback(id, path, callback);
        b->GetHost()->PrintToPDF(path, ps, cb);
    }
}

// ─── Utility ──────────────────────────────────────────────────────────────────

// NOTE: returned strings must be freed by the caller via free()
static char* AllocStr(const std::string& s) {
    char* buf = (char*)malloc(s.size() + 1);
    if (buf) { memcpy(buf, s.c_str(), s.size() + 1); }
    return buf;
}

AC_CEF_EXPORT const char* ac_cef_get_url(int64_t id) {
    if (auto b = GetBrowser(id))
        return AllocStr(b->GetMainFrame()->GetURL().ToString());
    return AllocStr("");
}

AC_CEF_EXPORT const char* ac_cef_get_title(int64_t id) {
    std::lock_guard<std::mutex> lk(g_browsers_mutex);
    if (auto* info = GetInfo(id))
        return AllocStr(info->title);
    return AllocStr("");
}

AC_CEF_EXPORT int ac_cef_can_go_back(int64_t id) {
    if (auto b = GetBrowser(id)) return b->CanGoBack() ? 1 : 0;
    return 0;
}

AC_CEF_EXPORT int ac_cef_can_go_forward(int64_t id) {
    if (auto b = GetBrowser(id)) return b->CanGoForward() ? 1 : 0;
    return 0;
}

AC_CEF_EXPORT int ac_cef_is_loading(int64_t id) {
    if (auto b = GetBrowser(id)) return b->IsLoading() ? 1 : 0;
    return 0;
}

} // extern "C"
