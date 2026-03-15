cmake_minimum_required(VERSION 3.28.3)

project(usd-exchange LANGUAGES CXX)

include(GNUInstallDirs)

# Ensure in Windows .dll and .exe end up in the same folders
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR}")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR}")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR}")

set(USDEX_VERSION "${PROJECT_VERSION}" CACHE STRING "OpenUSD Exchange SDK version string")
set(USDEX_BUILD_STRING "${USDEX_VERSION}" CACHE STRING "OpenUSD Exchange SDK build string")
set(USDEX_WITH_PYTHON "1" CACHE STRING "Build configured with Python support")
set(BUILD_SHARED_LIBS ON)

string(REPLACE "." ";" _usdex_version_tokens "${USDEX_VERSION}")
list(LENGTH _usdex_version_tokens _usdex_version_tokens_len)
if(_usdex_version_tokens_len GREATER 0)
    list(GET _usdex_version_tokens 0 USDEX_VERSION_MAJOR)
else()
    set(USDEX_VERSION_MAJOR 0)
endif()
if(_usdex_version_tokens_len GREATER 1)
    list(GET _usdex_version_tokens 1 USDEX_VERSION_MINOR)
else()
    set(USDEX_VERSION_MINOR 0)
endif()
if(_usdex_version_tokens_len GREATER 2)
    list(GET _usdex_version_tokens 2 USDEX_VERSION_PATCH)
else()
    set(USDEX_VERSION_PATCH 0)
endif()

find_package(OpenGL REQUIRED)
find_package(pxr REQUIRED)

set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)

file(GLOB_RECURSE USDEX_CORE_SOURCES CONFIGURE_DEPENDS source/core/library/*.cpp)
file(GLOB_RECURSE USDEX_RTX_SOURCES CONFIGURE_DEPENDS source/rtx/library/*.cpp)

set(USDEX_GENERATED_HEADER_DIR ${CMAKE_CURRENT_BINARY_DIR}/generated/headers)
set(USDEX_GENERATED_USDEX_DIR ${USDEX_GENERATED_HEADER_DIR}/usdex/core)
file(MAKE_DIRECTORY ${USDEX_GENERATED_USDEX_DIR})

configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/Feature.h.in
    ${USDEX_GENERATED_USDEX_DIR}/Feature.h
    @ONLY
)

configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/Version.h.in
    ${USDEX_GENERATED_USDEX_DIR}/Version.h
    @ONLY
)

add_library(usdex_core ${USDEX_CORE_SOURCES})
target_include_directories(
    usdex_core
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<BUILD_INTERFACE:${USDEX_GENERATED_HEADER_DIR}>
        $<BUILD_INTERFACE:${USDEX_GENERATED_USDEX_DIR}>
        $<INSTALL_INTERFACE:include>
        ${PXR_INCLUDE_DIRS}
    PRIVATE
        ${Python_INCLUDE_DIRS}
)
target_link_libraries(
    usdex_core
    PUBLIC
    ${PXR_LIBRARIES}
)
target_compile_features(usdex_core PUBLIC cxx_std_17)

add_library(usdex_rtx ${USDEX_RTX_SOURCES})
target_include_directories(
    usdex_rtx
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<BUILD_INTERFACE:${USDEX_GENERATED_HEADER_DIR}>
        $<BUILD_INTERFACE:${USDEX_GENERATED_USDEX_DIR}>
        $<INSTALL_INTERFACE:include>
    PRIVATE
        ${Python_INCLUDE_DIRS}
)
target_link_libraries(
    usdex_rtx
    PUBLIC
        usdex_core
)

set_target_properties(usdex_core PROPERTIES EXPORT_NAME usdex-core)
set_target_properties(usdex_rtx PROPERTIES EXPORT_NAME usdex-rtx)

include(CMakePackageConfigHelpers)
include(CTest)

install(
    TARGETS usdex_core usdex_rtx
    EXPORT usd-exchangeTargets
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

install(DIRECTORY include/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
install(
    FILES
        ${USDEX_GENERATED_USDEX_DIR}/Feature.h
        ${USDEX_GENERATED_USDEX_DIR}/Version.h
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/usdex/core
)

write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/usd-exchangeConfigVersion.cmake
    VERSION ${USDEX_VERSION}
    COMPATIBILITY AnyNewerVersion
)

configure_package_config_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/cmake/usd-exchangeConfig.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/usd-exchangeConfig.cmake
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/usd-exchange
)

install(
    FILES
        ${CMAKE_CURRENT_BINARY_DIR}/usd-exchangeConfig.cmake
        ${CMAKE_CURRENT_BINARY_DIR}/usd-exchangeConfigVersion.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/usd-exchange
)

install(
    EXPORT usd-exchangeTargets
    FILE usd-exchangeTargets.cmake
    NAMESPACE usd-exchange::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/usd-exchange
)

if(BUILD_TESTING)
    find_package(doctest CONFIG REQUIRED)
    file(GLOB_RECURSE USDEX_CORE_DOCTEST_SOURCES CONFIGURE_DEPENDS source/core/tests/doctest/*.cpp)
    add_executable(usdex_core_doctest ${USDEX_CORE_DOCTEST_SOURCES})
    target_link_libraries(usdex_core_doctest PRIVATE usdex_core doctest::doctest)
    add_test(NAME usdex-core-doctest COMMAND usdex_core_doctest)
endif()
