#pragma once

#include <flutter/dart_project.h>
#include <windows.h>
#include <filesystem>
#include <string>
#include <memory>

/**
 * ac_patches Windows Runtime Loader
 * 
 * Inspects the application patches directory and dynamically boots
 * the Flutter engine with the active OTA AOT snapshot if available,
 * seamlessly falling back to the base release app.so.
 */
class AcPatchesWindows {
public:
  static flutter::DartProject CreateDartProject() {
    std::filesystem::path exe_dir = GetExecutableDirectory();
    std::filesystem::path assets_path = exe_dir / L"data" / L"flutter_assets";
    std::filesystem::path icu_path = exe_dir / L"data" / L"icudtl.dat";
    std::filesystem::path aot_path = exe_dir / L"data" / L"app.so";

    // Check for active OTA patch
    std::filesystem::path patch_path = exe_dir / L"patches" / L"active" / L"app.so";
    if (std::filesystem::exists(patch_path)) {
      aot_path = patch_path;
    }

    return flutter::DartProject(assets_path, icu_path, aot_path);
  }

  static std::filesystem::path GetExecutableDirectory() {
    wchar_t buffer[MAX_PATH];
    GetModuleFileNameW(nullptr, buffer, MAX_PATH);
    return std::filesystem::path(buffer).parent_path();
  }
};
