#pragma once

#include <flutter_linux/flutter_linux.h>
#include <glib.h>
#include <unistd.h>
#include <limits.h>

/**
 * ac_patches Linux Runtime Loader
 * 
 * Inspects the application directory for active OTA patches and
 * configures the FlDartProject AOT library path before the engine initializes.
 */
static inline FlDartProject* ac_patches_create_linux_project() {
  FlDartProject* project = fl_dart_project_new();

  char exe_path[PATH_MAX];
  ssize_t len = readlink("/proc/self/exe", exe_path, sizeof(exe_path) - 1);
  if (len != -1) {
    exe_path[len] = '\0';
    g_autofree gchar* exe_dir = g_path_get_dirname(exe_path);
    g_autofree gchar* patch_path = g_build_filename(exe_dir, "patches", "active", "libapp.so", NULL);

    if (g_file_test(patch_path, G_FILE_TEST_EXISTS)) {
      fl_dart_project_set_aot_library_path(project, patch_path);
    }
  }

  return project;
}
