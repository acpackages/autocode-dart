#ifndef FLUTTER_PLUGIN_AC_PATCHES_WINDOWS_PLUGIN_H_
#define FLUTTER_PLUGIN_AC_PATCHES_WINDOWS_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace ac_patches_windows {

class AcPatchesWindowsPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  AcPatchesWindowsPlugin();

  virtual ~AcPatchesWindowsPlugin();

  // Disallow copy and assign.
  AcPatchesWindowsPlugin(const AcPatchesWindowsPlugin&) = delete;
  AcPatchesWindowsPlugin& operator=(const AcPatchesWindowsPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace ac_patches_windows

#endif  // FLUTTER_PLUGIN_AC_PATCHES_WINDOWS_PLUGIN_H_
