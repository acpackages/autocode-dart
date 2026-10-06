#include "include/ac_patches_windows/ac_patches_windows_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "ac_patches_windows_plugin.h"

void AcPatchesWindowsPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  ac_patches_windows::AcPatchesWindowsPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
