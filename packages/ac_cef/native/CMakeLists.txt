cmake_minimum_required(VERSION 3.19)
project(ac_cef_bridge CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# ─── Validate CEF_ROOT ────────────────────────────────────────────────────────
if(NOT DEFINED CEF_ROOT)
  message(FATAL_ERROR
    "CEF_ROOT is not set.\n"
    "Download a CEF binary distribution from:\n"
    "  https://cef-builds.spotifycdn.com/index.html\n"
    "(choose 'Windows 64-bit / Release')\n"
    "Then pass: cmake -DCEF_ROOT=C:/path/to/cef_binary_xxx_windows64 -B build")
endif()

# Normalise path separators on Windows
file(TO_CMAKE_PATH "${CEF_ROOT}" CEF_ROOT)
message(STATUS "Using CEF_ROOT: ${CEF_ROOT}")

# ─── CEF cmake helpers ────────────────────────────────────────────────────────
list(APPEND CMAKE_MODULE_PATH "${CEF_ROOT}/cmake")
find_package(CEF REQUIRED)

# ─── Build libcef_dll_wrapper (required by every CEF project) ─────────────────
add_subdirectory("${CEF_ROOT}/libcef_dll" libcef_dll_wrapper)

# ─── ac_cef_bridge shared library ────────────────────────────────────────────
add_library(ac_cef_bridge SHARED ac_cef_bridge.cpp)

target_include_directories(ac_cef_bridge PRIVATE
  "${CEF_ROOT}"
  "${CEF_ROOT}/include"
)

target_link_libraries(ac_cef_bridge PRIVATE
  libcef_dll_wrapper
  "${CEF_ROOT}/Release/libcef.lib"   # import library on Windows
)

# ─── jcef_helper (subprocess) ────────────────────────────────────────────────
add_executable(jcef_helper WIN32 jcef_helper.cpp)
target_include_directories(jcef_helper PRIVATE "${CEF_ROOT}" "${CEF_ROOT}/include")
target_link_libraries(jcef_helper PRIVATE 
  libcef_dll_wrapper
  "${CEF_ROOT}/Release/libcef.lib"
)
if(WIN32)
    set_property(TARGET jcef_helper PROPERTY MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
endif()

# Windows-specific compiler flags
if(WIN32)
  target_compile_definitions(ac_cef_bridge PRIVATE WIN32 _WINDOWS UNICODE _UNICODE NOMINMAX WIN32_LEAN_AND_MEAN)
  target_compile_definitions(jcef_helper PRIVATE WIN32 _WINDOWS UNICODE _UNICODE NOMINMAX WIN32_LEAN_AND_MEAN)
  
  # Use static CRT in Release to match CEF's build
  set_property(TARGET ac_cef_bridge PROPERTY MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
  set_property(TARGET jcef_helper PROPERTY MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
endif()

# ─── Output directories ───────────────────────────────────────────────────────
set(OUT_DIR "${CMAKE_BINARY_DIR}/out")

set_target_properties(ac_cef_bridge jcef_helper PROPERTIES
  RUNTIME_OUTPUT_DIRECTORY_RELEASE "${OUT_DIR}"
  RUNTIME_OUTPUT_DIRECTORY_DEBUG   "${OUT_DIR}"
  LIBRARY_OUTPUT_DIRECTORY         "${OUT_DIR}"
)

# ─── Copy CEF runtime files to OUT_DIR after build ──────────────────────────
# These are the files that must sit next to your Flutter .exe

set(CEF_RELEASE_DIR "${CEF_ROOT}/Release")
set(CEF_RESOURCES_DIR "${CEF_ROOT}/Resources")

# Core DLLs
set(CEF_DLLS
  "${CEF_RELEASE_DIR}/libcef.dll"
  "${CEF_RELEASE_DIR}/chrome_elf.dll"
  "${CEF_RELEASE_DIR}/d3dcompiler_47.dll"
  "${CEF_RELEASE_DIR}/libEGL.dll"
  "${CEF_RELEASE_DIR}/libGLESv2.dll"
  "${CEF_RELEASE_DIR}/vk_swiftshader.dll"
  "${CEF_RELEASE_DIR}/vulkan-1.dll"
)

# Resource files
set(CEF_RESOURCE_FILES
  "${CEF_RESOURCES_DIR}/icudtl.dat"
  "${CEF_RELEASE_DIR}/v8_context_snapshot.bin"
  "${CEF_RELEASE_DIR}/vk_swiftshader_icd.json"
  "${CEF_RESOURCES_DIR}/chrome_100_percent.pak"
  "${CEF_RESOURCES_DIR}/chrome_200_percent.pak"
  "${CEF_RESOURCES_DIR}/resources.pak"
)

add_custom_command(TARGET ac_cef_bridge POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E make_directory "${OUT_DIR}"
  COMMENT "Copying CEF runtime files to ${OUT_DIR}"
)

foreach(DLL ${CEF_DLLS})
  add_custom_command(TARGET ac_cef_bridge POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different "${DLL}" "${OUT_DIR}"
    COMMENT "Copying ${DLL}"
  )
endforeach()

foreach(RES ${CEF_RESOURCE_FILES})
  add_custom_command(TARGET ac_cef_bridge POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different "${RES}" "${OUT_DIR}"
    COMMENT "Copying ${RES}"
  )
endforeach()

# Copy locales directory
add_custom_command(TARGET ac_cef_bridge POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_directory
    "${CEF_RESOURCES_DIR}/locales" "${OUT_DIR}/locales"
  COMMENT "Copying CEF locales"
)

# ─── Summary ─────────────────────────────────────────────────────────────────
message(STATUS "")
message(STATUS "ac_cef_bridge build summary:")
message(STATUS "  Output directory : ${OUT_DIR}")
message(STATUS "  CEF root         : ${CEF_ROOT}")
message(STATUS "")
message(STATUS "After building, copy ${OUT_DIR}/* next to your Flutter .exe")
message(STATUS "")
