#include "ac_patches_windows_plugin.h"

#include <windows.h>
#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <filesystem>

namespace ac_patches_windows {

// static
void AcPatchesWindowsPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "ac_patches/windows",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<AcPatchesWindowsPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

AcPatchesWindowsPlugin::AcPatchesWindowsPlugin() {}

AcPatchesWindowsPlugin::~AcPatchesWindowsPlugin() {}

void AcPatchesWindowsPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("getActivePatchPath") == 0) {
    wchar_t buffer[MAX_PATH];
    GetModuleFileNameW(nullptr, buffer, MAX_PATH);
    std::filesystem::path exe_dir = std::filesystem::path(buffer).parent_path();
    std::filesystem::path patch_path = exe_dir / L"patches" / L"active" / L"app.so";

    if (std::filesystem::exists(patch_path)) {
      result->Success(flutter::EncodableValue(patch_path.string()));
    } else {
      result->Success(flutter::EncodableValue());
    }
  } else if (method_call.method_name().compare("isPatchInstalled") == 0) {
    wchar_t buffer[MAX_PATH];
    GetModuleFileNameW(nullptr, buffer, MAX_PATH);
    std::filesystem::path exe_dir = std::filesystem::path(buffer).parent_path();
    std::filesystem::path patch_path = exe_dir / L"patches" / L"active" / L"app.so";

    result->Success(flutter::EncodableValue(std::filesystem::exists(patch_path)));
  } else {
    result->NotImplemented();
  }
}

}  // namespace ac_patches_windows
