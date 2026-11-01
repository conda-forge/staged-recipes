# Shared library and CMake package for QCustomPlot (upstream ships the
# amalgamated sources and a qmake project for the shared library)
cmake_minimum_required(VERSION 3.16)
project(qcustomplot VERSION 2.1.1 LANGUAGES CXX)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOMOC ON)
find_package(Qt6 REQUIRED COMPONENTS Core Gui Widgets PrintSupport)

add_library(qcustomplot qcustomplot.cpp qcustomplot.h)
add_library(qcustomplot::qcustomplot ALIAS qcustomplot)
set_target_properties(qcustomplot PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_VERSION_MAJOR}
    PUBLIC_HEADER qcustomplot.h
)
target_compile_definitions(qcustomplot PRIVATE QCUSTOMPLOT_COMPILE_LIBRARY)
target_compile_definitions(qcustomplot INTERFACE QCUSTOMPLOT_USE_LIBRARY)
target_include_directories(qcustomplot PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)
target_link_libraries(qcustomplot PUBLIC Qt6::Core Qt6::Gui Qt6::Widgets Qt6::PrintSupport)

install(TARGETS qcustomplot EXPORT qcustomplotTargets
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)
set(CONFIG_DIR ${CMAKE_INSTALL_LIBDIR}/cmake/qcustomplot)
install(EXPORT qcustomplotTargets NAMESPACE qcustomplot::
    FILE qcustomplot-targets.cmake DESTINATION ${CONFIG_DIR})
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/qcustomplot-config.cmake
"include(CMakeFindDependencyMacro)
find_dependency(Qt6 COMPONENTS Core Gui Widgets PrintSupport)
include(\${CMAKE_CURRENT_LIST_DIR}/qcustomplot-targets.cmake)
")
write_basic_package_version_file(qcustomplot-config-version.cmake
    COMPATIBILITY SameMinorVersion)
install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/qcustomplot-config.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/qcustomplot-config-version.cmake
    DESTINATION ${CONFIG_DIR})
