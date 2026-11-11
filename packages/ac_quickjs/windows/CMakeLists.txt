cmake_minimum_required(VERSION 3.14)

# Project-level configuration.
set(PROJECT_NAME "ac_quickjs")
project(${PROJECT_NAME} LANGUAGES CXX)

set(PREBUILT_DLL "${CMAKE_CURRENT_SOURCE_DIR}/../native/windows/x64/ac_quickjs.dll")

if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/../cargokit/cmake/cargokit.cmake")
  include("../cargokit/cmake/cargokit.cmake")
  apply_cargokit(${PROJECT_NAME} ../rust ac_quickjs "")
endif()

# Ensure fallback to prebuilt native DLL if cargokit output is not defined or built
if(DEFINED ${PROJECT_NAME}_cargokit_lib AND TARGET ${PROJECT_NAME}_cargokit)
  set(ac_quickjs_bundled_libraries
    "${${PROJECT_NAME}_cargokit_lib}"
    PARENT_SCOPE
  )
elseif(EXISTS "${PREBUILT_DLL}")
  set(ac_quickjs_bundled_libraries
    "${PREBUILT_DLL}"
    PARENT_SCOPE
  )
endif()

