# Install wrapper for the header-only MCAP C++ library.
#
# Upstream (foxglove/mcap, cpp/mcap) ships only the headers plus a Conan
# recipe; there is no CMake build/install. This installs the headers and a
# CMake package providing the INTERFACE target mcap::mcap, which carries the
# lz4 and zstd dependencies needed by the reader/writer implementation.
cmake_minimum_required(VERSION 3.16)
project(mcap_install LANGUAGES NONE)

set(MCAP_SOURCE_DIR "" CACHE PATH "MCAP C++ library directory (cpp/mcap)")
set(MCAP_VERSION "" CACHE STRING "MCAP C++ library version")

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

install(DIRECTORY "${MCAP_SOURCE_DIR}/include/mcap"
  DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

set(_cmakedir ${CMAKE_INSTALL_DATADIR}/cmake/mcap)
configure_package_config_file(mcap-config.cmake.in
  "${CMAKE_CURRENT_BINARY_DIR}/mcap-config.cmake"
  INSTALL_DESTINATION ${_cmakedir}
  PATH_VARS CMAKE_INSTALL_INCLUDEDIR)
write_basic_package_version_file(
  "${CMAKE_CURRENT_BINARY_DIR}/mcap-config-version.cmake"
  VERSION ${MCAP_VERSION}
  COMPATIBILITY SameMajorVersion
  ARCH_INDEPENDENT)
install(FILES
    "${CMAKE_CURRENT_BINARY_DIR}/mcap-config.cmake"
    "${CMAKE_CURRENT_BINARY_DIR}/mcap-config-version.cmake"
  DESTINATION ${_cmakedir})
