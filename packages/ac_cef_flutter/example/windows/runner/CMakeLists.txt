cmake_minimum_required(VERSION 3.14)
project(runner LANGUAGES CXX)

# Define the application target. To change its name, change BINARY_NAME in the
# top-level CMakeLists.txt, not the value here, or `flutter run` will no longer
# work.
#
# Any new source files that you add to the application should be added here.
add_executable(${BINARY_NAME} WIN32
  "flutter_window.cpp"
  "main.cpp"
  "utils.cpp"
  "win32_window.cpp"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
  "Runner.rc"
  "runner.exe.manifest"
)

# Apply the standard set of build settings. This can be removed for applications
# that need different build settings.
apply_standard_settings(${BINARY_NAME})

# Add preprocessor definitions for the build version.
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION=\"${FLUTTER_VERSION}\"")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MAJOR=${FLUTTER_VERSION_MAJOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_MINOR=${FLUTTER_VERSION_MINOR}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_PATCH=${FLUTTER_VERSION_PATCH}")
target_compile_definitions(${BINARY_NAME} PRIVATE "FLUTTER_VERSION_BUILD=${FLUTTER_VERSION_BUILD}")

# Disable Windows macros that collide with C++ standard library functions.
target_compile_definitions(${BINARY_NAME} PRIVATE "NOMINMAX")

# Add dependency libraries and include directories. Add any application-specific
# dependencies here.
target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app)
target_link_libraries(${BINARY_NAME} PRIVATE "dwmapi.lib")
target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")

# Run the Flutter tool portions of the build. This must not be removed.
add_dependencies(${BINARY_NAME} flutter_assemble)

# Post-build step to copy CEF runtime binaries, bridge, helper, and resources
set(AC_CEF_OUT_DIR "F:/Packages/AutoCode/Github/autocode-dart/packages/ac_cef/native/build_win/out")
if(EXISTS "${AC_CEF_OUT_DIR}")
  set(CEF_FILES_TO_COPY
    "ac_cef_bridge.dll"
    "ac_cef_helper.exe"
    "libcef.dll"
    "chrome_elf.dll"
    "d3dcompiler_47.dll"
    "libEGL.dll"
    "libGLESv2.dll"
    "vk_swiftshader.dll"
    "vk_swiftshader_icd.json"
    "vulkan-1.dll"
    "icudtl.dat"
    "v8_context_snapshot.bin"
    "resources.pak"
    "chrome_100_percent.pak"
    "chrome_200_percent.pak"
  )
  foreach(CEF_FILE ${CEF_FILES_TO_COPY})
    if(EXISTS "${AC_CEF_OUT_DIR}/${CEF_FILE}")
      add_custom_command(TARGET ${BINARY_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${AC_CEF_OUT_DIR}/${CEF_FILE}"
        "$<TARGET_FILE_DIR:${BINARY_NAME}>/${CEF_FILE}"
      )
    endif()
  endforeach()
  if(EXISTS "${AC_CEF_OUT_DIR}/locales")
    add_custom_command(TARGET ${BINARY_NAME} POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy_directory
      "${AC_CEF_OUT_DIR}/locales"
      "$<TARGET_FILE_DIR:${BINARY_NAME}>/locales"
    )
  endif()
endif()
