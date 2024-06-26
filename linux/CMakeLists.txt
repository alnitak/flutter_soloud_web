cmake_minimum_required(VERSION 3.10)
set(PROJECT_NAME "flutter_soloud")
project(${PROJECT_NAME} LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
# set(CMAKE_CXX_EXTENSIONS OFF)
# set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -v -fvisibility=hidden")
# set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -v -fvisibility=hidden")

set(PLUGIN_NAME "${PROJECT_NAME}_plugin")

set(SRC_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../src")

## Add SoLoud custom cmake files
message("**************** SOLOUD CONFIGURE.CMAKE")
include (Configure.cmake)
message("**************** SOLOUD SRC.CMAKE 1")
if (UNIX AND NOT WIN32 AND NOT APPLE)
	if (CMAKE_SIZEOF_VOID_P MATCHES "8")
		set (LIB_POSTFIX "64" CACHE STRING "suffix for 32/64 dir placement")
		mark_as_advanced (LIB_POSTFIX)
	endif ()
endif ()
if (MSVC)
	add_definitions (-D_CRT_SECURE_NO_WARNINGS)
endif()
if (NOT DEFINED LIB_POSTFIX)
	set (LIB_POSTFIX "")
endif ()

include_directories(${SRC_DIR}/soloud/include)
include_directories(${SRC_DIR}/soloud/src)
include (src.cmake)
message("**************** SOLOUD SRC.CMAKE 2  ${TARGET_NAME}")




list(APPEND PLUGIN_SOURCES
  "${SRC_DIR}/common.cpp"
  "${SRC_DIR}/bindings.cpp"
  "${SRC_DIR}/player.cpp"
  "${SRC_DIR}/analyzer.cpp"
  "${SRC_DIR}/bindings_capture.cpp"
  "${SRC_DIR}/capture.cpp"
  "${SRC_DIR}/synth/basic_wave.cpp"
  "${SRC_DIR}/filters/filters.cpp"
  ${TARGET_SOURCES}
)

add_library(${PLUGIN_NAME} SHARED
  ${PLUGIN_SOURCES}
)
apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)


  
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter)
target_link_libraries(${PLUGIN_NAME} PRIVATE PkgConfig::GTK)

target_compile_options("${PLUGIN_NAME}" PRIVATE -Wall -Wno-error -fPIC) #  -ldl -lpthread -lm

# List of absolute paths to libraries that should be bundled with the plugin.
set(flutter_soloud_bundled_libraries
  $<TARGET_FILE:${PLUGIN_NAME}>
  PARENT_SCOPE
)

# === Tests ===
# These unit tests can be run from a terminal after building the example.

# Only enable test builds when building the example (which sets this variable)
# so that plugin clients aren't building the tests.
# if (${include_${PROJECT_NAME}_tests})
# if(${CMAKE_VERSION} VERSION_LESS "3.11.0")
# message("Unit tests require CMake 3.11.0 or later")
# else()
# set(TEST_RUNNER "${PROJECT_NAME}_test")
# enable_testing()

# # Add the Google Test dependency.
# include(FetchContent)
# FetchContent_Declare(
#   googletest
#   URL https://github.com/google/googletest/archive/release-1.11.0.zip
# )
# # Prevent overriding the parent project's compiler/linker settings
# set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
# # Disable install commands for gtest so it doesn't end up in the bundle.
# set(INSTALL_GTEST OFF CACHE BOOL "Disable installation of googletest" FORCE)

# FetchContent_MakeAvailable(googletest)

# # The plugin's exported API is not very useful for unit testing, so build the
# # sources directly into the test binary rather than using the shared library.
# add_executable(${TEST_RUNNER}
#   test/flutter_soloud_plugin_test.cc
#   ${PLUGIN_SOURCES}
# )
# apply_standard_settings(${TEST_RUNNER})
# target_include_directories(${TEST_RUNNER} PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}")
# target_link_libraries(${TEST_RUNNER} PRIVATE flutter)
# target_link_libraries(${TEST_RUNNER} PRIVATE PkgConfig::GTK)
# target_link_libraries(${TEST_RUNNER} PRIVATE gtest_main gmock)

# # Enable automatic test discovery.
# include(GoogleTest)
# gtest_discover_tests(${TEST_RUNNER})

# endif()  # CMake version check
# endif()  # include_${PROJECT_NAME}_tests