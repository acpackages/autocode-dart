enum CefLogSeverity {
  defaultSeverity,
  verbose,
  info,
  warning,
  error,
  fatal,
  disable,
}

/// CEF initialization settings.
///
/// Maps directly to CEF's `cef_settings_t`. Use [toMap] to serialize
/// all non-null fields into a key/value map for the native bridge.
class CefSettings {
  String? browserSubprocessPath;
  bool windowlessRenderingEnabled;
  bool commandLineArgsDisabled;
  String? cachePath;
  bool persistSessionCookies;
  String? userAgent;
  String? userAgentProduct;
  String? locale;
  String? logFile;
  CefLogSeverity logSeverity;
  String? javascriptFlags;
  String? resourcesDirPath;
  String? localesDirPath;
  int remoteDebuggingPort;
  String? chromePolicyId;
  int uncaughtExceptionStackSize;
  int? backgroundColor;
  String? cookieableSchemesList;
  bool cookieableSchemesExcludeDefaults;
  bool noSandbox;

  /// Create settings with sensible defaults.
  ///
  /// All parameters are optional — only set what you need.
  CefSettings({
    this.browserSubprocessPath,
    this.windowlessRenderingEnabled = true,
    this.commandLineArgsDisabled = false,
    this.cachePath,
    this.persistSessionCookies = false,
    this.userAgent,
    this.userAgentProduct,
    this.locale,
    this.logFile,
    this.logSeverity = CefLogSeverity.defaultSeverity,
    this.javascriptFlags,
    this.resourcesDirPath,
    this.localesDirPath,
    this.remoteDebuggingPort = 0,
    this.chromePolicyId,
    this.uncaughtExceptionStackSize = 0,
    this.backgroundColor,
    this.cookieableSchemesList,
    this.cookieableSchemesExcludeDefaults = false,
    this.noSandbox = false,
  });

  /// Serialize all settings into a `Map<String, String>` for the native bridge.
  Map<String, String> toMap() {
    final result = <String, String>{};
    if (browserSubprocessPath != null) {
      result['browser_subprocess_path'] = browserSubprocessPath!;
    }
    result['windowless_rendering_enabled'] =
        windowlessRenderingEnabled.toString();
    result['command_line_args_disabled'] =
        commandLineArgsDisabled.toString();
    if (cachePath != null) result['cache_path'] = cachePath!;
    result['persist_session_cookies'] = persistSessionCookies.toString();
    if (userAgent != null) result['user_agent'] = userAgent!;
    if (userAgentProduct != null) result['user_agent_product'] = userAgentProduct!;
    if (locale != null) result['locale'] = locale!;
    if (logFile != null) result['log_file'] = logFile!;
    result['log_severity'] = logSeverity.name;
    if (javascriptFlags != null) result['javascript_flags'] = javascriptFlags!;
    if (resourcesDirPath != null) result['resources_dir_path'] = resourcesDirPath!;
    if (localesDirPath != null) result['locales_dir_path'] = localesDirPath!;
    result['remote_debugging_port'] = remoteDebuggingPort.toString();
    if (chromePolicyId != null) result['chrome_policy_id'] = chromePolicyId!;
    result['uncaught_exception_stack_size'] =
        uncaughtExceptionStackSize.toString();
    if (backgroundColor != null) {
      result['background_color'] = backgroundColor!.toString();
    }
    if (cookieableSchemesList != null) {
      result['cookieable_schemes_list'] = cookieableSchemesList!;
    }
    result['cookieable_schemes_exclude_defaults'] =
        cookieableSchemesExcludeDefaults.toString();
    result['no_sandbox'] = noSandbox.toString();
    return result;
  }
}
