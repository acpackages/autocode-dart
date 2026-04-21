class CefBrowserSettings {
  int windowlessFrameRate = 0;
  bool sharedTexturesEnabled = false;

  CefBrowserSettings();

  CefBrowserSettings clone() {
    return CefBrowserSettings()
      ..windowlessFrameRate = windowlessFrameRate
      ..sharedTexturesEnabled = sharedTexturesEnabled;
  }
}
