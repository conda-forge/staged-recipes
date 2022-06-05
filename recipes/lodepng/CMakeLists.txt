cmake_minimum_required(VERSION 3.23)

include(GNUInstallDirs)

project(lodepng
        VERSION "$ENV{PKG_VERSION}"
        LANGUAGES CXX)

# To build shared libraries in Windows, we set CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS to TRUE.
# See https://cmake.org/cmake/help/v3.4/variable/CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS.html
# See https://blog.kitware.com/create-dlls-on-windows-without-declspec-using-new-cmake-export-all-feature/
set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)

add_library(lodepng lodepng.cpp)

target_include_directories(lodepng PUBLIC
  $<INSTALL_INTERFACE:include>
)

set(LODEPNG_CMAKE_INSTALL_DIR lib/cmake/lodepng)

file(WRITE "${CMAKE_BINARY_DIR}/lodepng-config.cmake" 
           "include(\"\${CMAKE_CURRENT_LIST_DIR}/lodepng-targets.cmake\")")
           
write_basic_package_version_file("${CMAKE_BINARY_DIR}/lodepng-config-version.cmake" 
                                 COMPATIBILITY AnyNewerVersion)

install(FILES "${CMAKE_BINARY_DIR}/lodepng-config.cmake"
              "${CMAKE_BINARY_DIR}/lodepng-config-version.cmake"
        DESTINATION ${LODEPNG_CMAKE_INSTALL_DIR})

install(TARGETS lodepng 
        EXPORT lodepng-targets)

install(EXPORT lodepng-targets 
        DESTINATION ${LODEPNG_CMAKE_INSTALL_DIR})

install(FILES lodepng.h 
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
