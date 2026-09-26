# Stub Tracy CMakeLists.txt for conda-forge builds
# Mumble unconditionally links to Tracy::TracyClient and calls tracy::SetThreadName
# directly (not through macros), so the symbol must be provided even when
# TRACY_ENABLE is OFF.  This stub compiles a tiny no-op implementation so the
# linker is satisfied without requiring the full Tracy source tree.
cmake_minimum_required(VERSION 3.15)

if(NOT TARGET TracyClient)
    add_library(TracyClient STATIC TracyStub.cpp)
    target_include_directories(TracyClient INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}")
    add_library(Tracy::TracyClient ALIAS TracyClient)
endif()
