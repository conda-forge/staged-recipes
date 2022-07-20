cmake_minimum_required(VERSION 3.10)

project(visit_struct LANGUAGES CXX VERSION "$ENV{PKG_VERSION}")

add_library(visit_struct INTERFACE)
add_library(visit_struct::visit_struct ALIAS visit_struct)

include(GNUInstallDirs)

target_include_directories(visit_struct INTERFACE "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
                                                  "$<INSTALL_INTERFACE:$<INSTALL_PREFIX>/${CMAKE_INSTALL_INCLUDEDIR}>")

install(DIRECTORY include/visit_struct
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})

install(TARGETS visit_struct
        EXPORT visit_struct)

set(VISIT_STRUCT_CMAKE_INSTALL_DIR share/visit_struct)

install(EXPORT visit_struct
        FILE visit_struct-config.cmake
        NAMESPACE visit_struct::
        DESTINATION ${VISIT_STRUCT_CMAKE_INSTALL_DIR})

include(CMakePackageConfigHelpers)
write_basic_package_version_file("${CMAKE_BINARY_DIR}/visit_struct-version.cmake"
                                 COMPATIBILITY ExactVersion)

install(FILES "${CMAKE_BINARY_DIR}/visit_struct-version.cmake"
        DESTINATION ${VISIT_STRUCT_CMAKE_INSTALL_DIR})
