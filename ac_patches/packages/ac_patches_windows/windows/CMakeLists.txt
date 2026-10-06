cmake_minimum_required(VERSION 3.14)
project(ac_patches_windows LANGUAGES CXX)

set(PLUGIN_NAME "ac_patches_windows_plugin")

add_library(${PLUGIN_NAME} SHARED
  "ac_patches_windows_plugin.cpp"
  "ac_patches_windows_plugin_c_api.cpp"
)

apply_standard_settings(${PLUGIN_NAME})

set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET "hidden"
  VISIBILITY_INLINES_HIDDEN 1
)

target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)

target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")

target_link_libraries(${PLUGIN_NAME} PRIVATE flutter flutter_wrapper_plugin)

# List of absolute paths to libraries that should be bundled with the plugin
set(ac_patches_windows_bundled_libraries
  ""
  PARENT_SCOPE
)
