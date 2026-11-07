# Shared library and CMake package for dxflib (upstream builds it only as part
# of QCAD, as a static library)
cmake_minimum_required(VERSION 3.16)
project(dxflib VERSION 3.26.4 LANGUAGES CXX)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

set(HEADERS
    src/dl_attributes.h src/dl_codes.h src/dl_creationadapter.h
    src/dl_creationinterface.h src/dl_dxf.h src/dl_entities.h
    src/dl_exception.h src/dl_extrusion.h src/dl_global.h src/dl_writer.h
    src/dl_writer_ascii.h
)
add_library(dxflib src/dl_dxf.cpp src/dl_writer_ascii.cpp ${HEADERS})
add_library(dxflib::dxflib ALIAS dxflib)
set_target_properties(dxflib PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_VERSION_MAJOR}
    PUBLIC_HEADER "${HEADERS}"
)
target_compile_definitions(dxflib PRIVATE DXFLIB_LIBRARY)
if(BUILD_SHARED_LIBS)
    target_compile_definitions(dxflib PUBLIC DXFLIB_DLL)
endif()
if(MSVC)
    target_compile_definitions(dxflib PRIVATE _CRT_SECURE_NO_WARNINGS)
endif()
target_include_directories(dxflib PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/src>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/dxflib>
)

install(TARGETS dxflib EXPORT dxflibTargets
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/dxflib
)
install(EXPORT dxflibTargets NAMESPACE dxflib::
    FILE dxflib-config.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/dxflib
)
write_basic_package_version_file(dxflib-config-version.cmake
    COMPATIBILITY SameMinorVersion)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/dxflib-config-version.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/dxflib
)
