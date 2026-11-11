cmake_minimum_required(VERSION 3.10)

# Project-level configuration.
set(PROJECT_NAME "ac_quickjs")
project(${PROJECT_NAME} LANGUAGES CXX)

set(PREBUILT_SO "${CMAKE_CURRENT_SOURCE_DIR}/../native/linux/x64/libac_quickjs.so")

if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/../cargokit/cmake/cargokit.cmake")
  include("../cargokit/cmake/cargokit.cmake")
  apply_cargokit(${PROJECT_NAME} ../rust ac_quickjs "")
endif()

# Ensure fallback to prebuilt native SO if cargokit output is not defined or built
if(DEFINED ${PROJECT_NAME}_cargokit_lib AND TARGET ${PROJECT_NAME}_cargokit)
  set(ac_quickjs_bundled_libraries
    "${${PROJECT_NAME}_cargokit_lib}"
    PARENT_SCOPE
  )
elseif(EXISTS "${PREBUILT_SO}")
  set(ac_quickjs_bundled_libraries
    "${PREBUILT_SO}"
    PARENT_SCOPE
  )
endif()

