cmake_minimum_required(VERSION 3.14)

# Project-level configuration.
set(PROJECT_NAME "ac_quickjs")
project(${PROJECT_NAME} LANGUAGES CXX)

include("../cargokit/cmake/cargokit.cmake")
apply_cargokit(${PROJECT_NAME} ../libfjs ac_quickjs "")

# List of absolute paths to libraries that should be bundled with the plugin.
set(ac_quickjs_bundled_libraries
  "${${PROJECT_NAME}_cargokit_lib}"
  PARENT_SCOPE
)
