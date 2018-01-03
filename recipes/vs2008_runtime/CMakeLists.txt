cmake_minimum_required(VERSION 3.1)

project(vs2008_runtime)

enable_language(C)
enable_language(CXX)

include(InstallRequiredSystemLibraries)

if (NOT "${CMAKE_CXX_COMPILER_VERSION}" STREQUAL "$ENV{PKG_VERSION}")
    message(FATAL_ERROR "Compiler version detected ${CMAKE_CXX_COMPILER_VERSION} "
                        "does not match version of package being built $ENV{PKG_VERSION}\n"
                        "Do you have current updates for VS 2008 installed?")
endif()
