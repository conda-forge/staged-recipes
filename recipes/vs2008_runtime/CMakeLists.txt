cmake_minimum_required(VERSION 3.1)

project(vs2008_runtime)

enable_language(C)
enable_language(CXX)

include(InstallRequiredSystemLibraries)

string(SUBSTRING "${CMAKE_CXX_COMPILER_VERSION}" 2 -1 EXPECTED_VERSION)
set(EXPECTED_VERSION "9${EXPECTED_VERSION}")

if (NOT "${EXPECTED_VERSION}" STREQUAL "$ENV{PKG_VERSION}")
    message(FATAL_ERROR "VC runtime version detected ${EXPECTED_VERSION} "
                        "does not match version of package being built $ENV{PKG_VERSION}\n"
                        "Do you have current updates for VS 2008 installed?")
endif()
