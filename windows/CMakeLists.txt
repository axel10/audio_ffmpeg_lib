# The Flutter tooling requires that developers have a version of Visual Studio
# installed that includes CMake 3.14 or later. You should not increase this
# version, as doing so will cause the plugin to fail to compile for some
# customers of the plugin.
cmake_minimum_required(VERSION 3.14)

# Project-level configuration.
set(PROJECT_NAME "audio_ffmpeg_lib")
project(${PROJECT_NAME} LANGUAGES CXX)

# Explicitly opt in to modern CMake behaviors to avoid warnings with recent
# versions of CMake.
cmake_policy(VERSION 3.14...3.25)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "audio_ffmpeg_lib_plugin")

# Any new source files that you add to the plugin should be added here.
list(APPEND PLUGIN_SOURCES
  "audio_ffmpeg_lib_plugin.cpp"
  "audio_ffmpeg_lib_plugin.h"
)

# Define the plugin library target. Its name must not be changed (see comment
# on PLUGIN_NAME above).
add_library(${PLUGIN_NAME} SHARED
  "include/audio_ffmpeg_lib/audio_ffmpeg_lib_plugin_c_api.h"
  "audio_ffmpeg_lib_plugin_c_api.cpp"
  ${PLUGIN_SOURCES}
)

# Apply a standard set of build settings that are configured in the
# application-level CMakeLists.txt. This can be removed for plugins that want
# full control over build settings.
apply_standard_settings(${PLUGIN_NAME})

# Symbols are hidden by default to reduce the chance of accidental conflicts
# between plugins. This should not be removed; any symbols that should be
# exported should be explicitly exported with the FLUTTER_PLUGIN_EXPORT macro.
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)

# Source include directories and library dependencies. Add any plugin-specific
# dependencies here.
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")

set(_ffmpeg_install_hint [=[
Copy the 'ffmpeg-vibeflow-audio' folder to an overlay directory such as:
  D:/vcpkg/overlay-ports/ffmpeg-vibeflow-audio

Then install it with vcpkg using the custom triplet:
  New-Item -ItemType Directory -Force D:/vcpkg/overlay-ports | Out-Null
  Copy-Item -Recurse -Force .\ffmpeg-vibeflow-audio D:/vcpkg/overlay-ports/ffmpeg-vibeflow-audio
  $env:VCPKG_OVERLAY_PORTS='D:/vcpkg/overlay-ports'
  $env:VCPKG_OVERLAY_TRIPLETS='D:/vcpkg/overlay-ports/ffmpeg-vibeflow-audio/triplets'
  vcpkg install ffmpeg-vibeflow-audio:x64-windows-audio --overlay-ports=$env:VCPKG_OVERLAY_PORTS --overlay-triplets=$env:VCPKG_OVERLAY_TRIPLETS
]=])

# Find FFmpeg components.
# This plugin is intentionally pinned to the custom ffmpeg-vibeflow-audio build.
set(_ffmpeg_triplet "x64-windows-audio")
set(_ffmpeg_search_paths)
if(DEFINED VCPKG_INSTALLED_DIR)
  list(APPEND _ffmpeg_search_paths "${VCPKG_INSTALLED_DIR}/${_ffmpeg_triplet}")
endif()
list(APPEND _ffmpeg_search_paths "D:/vcpkg/installed/${_ffmpeg_triplet}")

find_path(FFMPEG_INCLUDE_DIR NAMES libavcodec/avcodec.h PATHS ${_ffmpeg_search_paths} PATH_SUFFIXES include)
if(NOT FFMPEG_INCLUDE_DIR)
  message(FATAL_ERROR
    "FFmpeg headers not found for the custom ffmpeg-vibeflow-audio build.\n"
    "${_ffmpeg_install_hint}\n"
    "Search paths:\n"
    "  ${_ffmpeg_search_paths}")
endif()
target_include_directories(${PLUGIN_NAME} PRIVATE ${FFMPEG_INCLUDE_DIR})

target_link_libraries(${PLUGIN_NAME} PRIVATE 
  flutter 
  flutter_wrapper_plugin
)

foreach(lib avcodec avformat avfilter swresample avutil)
  find_library(FFMPEG_${lib}_LIBRARY NAMES ${lib} PATHS ${_ffmpeg_search_paths} PATH_SUFFIXES lib)
  if(NOT FFMPEG_${lib}_LIBRARY)
    message(FATAL_ERROR
      "Required FFmpeg library '${lib}' not found for the custom ffmpeg-vibeflow-audio build.\n"
      "${_ffmpeg_install_hint}\n"
      "Search paths:\n"
      "  ${_ffmpeg_search_paths}")
  endif()
  target_link_libraries(${PLUGIN_NAME} PRIVATE ${FFMPEG_${lib}_LIBRARY})
endforeach()

# List of absolute paths to libraries that should be bundled with the plugin.
# This list could contain prebuilt libraries, or libraries created by an
# external build triggered from this build file.
set(audio_ffmpeg_lib_bundled_libraries)

set(_ffmpeg_bin_dir "D:/vcpkg/installed/${_ffmpeg_triplet}/bin")
if(DEFINED VCPKG_INSTALLED_DIR)
  set(_ffmpeg_bin_dir "${VCPKG_INSTALLED_DIR}/${_ffmpeg_triplet}/bin")
endif()

file(GLOB _vcpkg_dlls CONFIGURE_DEPENDS
  "${_ffmpeg_bin_dir}/*.dll")
if(NOT _vcpkg_dlls)
  message(FATAL_ERROR
    "Required FFmpeg DLLs not found for the custom ffmpeg-vibeflow-audio build.\n"
    "${_ffmpeg_install_hint}\n"
    "Expected DLL directory:\n"
    "  ${_ffmpeg_bin_dir}")
endif()
list(APPEND audio_ffmpeg_lib_bundled_libraries ${_vcpkg_dlls})

if(NOT CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
  set(audio_ffmpeg_lib_bundled_libraries "${audio_ffmpeg_lib_bundled_libraries}" PARENT_SCOPE)
endif()

# === Tests ===
# These unit tests can be run from a terminal after building the example, or
# from Visual Studio after opening the generated solution file.

# Only enable test builds when building the example (which sets this variable)
# so that plugin clients aren't building the tests.
if (${include_${PROJECT_NAME}_tests})
set(TEST_RUNNER "${PROJECT_NAME}_test")
enable_testing()

# Add the Google Test dependency.
include(FetchContent)
FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/refs/tags/v1.15.2.zip
)
# Prevent overriding the parent project's compiler/linker settings
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
# Disable install commands for gtest so it doesn't end up in the bundle.
set(INSTALL_GTEST OFF CACHE BOOL "Disable installation of googletest" FORCE)
FetchContent_MakeAvailable(googletest)

# The plugin's C API is not very useful for unit testing, so build the sources
# directly into the test binary rather than using the DLL.
add_executable(${TEST_RUNNER}
  test/audio_ffmpeg_lib_plugin_test.cpp
  ${PLUGIN_SOURCES}
)
apply_standard_settings(${TEST_RUNNER})
target_include_directories(${TEST_RUNNER} PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}")
target_link_libraries(${TEST_RUNNER} PRIVATE flutter_wrapper_plugin)
target_link_libraries(${TEST_RUNNER} PRIVATE gtest_main gmock)
# flutter_wrapper_plugin has link dependencies on the Flutter DLL.
add_custom_command(TARGET ${TEST_RUNNER} POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_if_different
  "${FLUTTER_LIBRARY}" $<TARGET_FILE_DIR:${TEST_RUNNER}>
)

# Enable automatic test discovery.
include(GoogleTest)
gtest_discover_tests(${TEST_RUNNER})
endif()
