cmake_minimum_required(VERSION 3.10)

project(speexdsp
    VERSION 1.2.1
    DESCRIPTION "speexdsp audio processing library"
    LANGUAGES C CXX
)
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

option(BUILD_SHARED_LIBS "Build shared libraries" ON)
option(USE_FIXED_POINT "Use fixed-point arithmetic" ON)

# Define compile-time options
if(USE_FIXED_POINT)
    add_compile_definitions(FIXED_POINT=1)
else()
    add_compile_definitions(FLOATING_POINT=1)
endif()

# 'M_PI': undeclared identifier
if(WIN32)
    add_compile_definitions(_USE_MATH_DEFINES=1)
endif()


# Check for standard integer types and set size variables
include(CheckIncludeFile)
include(CheckTypeSize)

check_include_file(stdint.h HAVE_STDINT_H)
if(HAVE_STDINT_H)
    set(INCLUDE_STDINT 1)
endif()

# Check sizes of integer types
check_type_size("short" SIZEOF_SHORT)
check_type_size("int" SIZEOF_INT)
check_type_size("long" SIZEOF_LONG)

# Set type definitions based on size checks
if(SIZEOF_SHORT EQUAL 2)
    set(SIZE16 "short")
    set(USIZE16 "unsigned short")
elseif(SIZEOF_INT EQUAL 2)
    set(SIZE16 "int")
    set(USIZE16 "unsigned int")
else()
    set(SIZE16 "int16_t")
    set(USIZE16 "uint16_t")
endif()

if(SIZEOF_INT EQUAL 4)
    set(SIZE32 "int")
    set(USIZE32 "unsigned int")
elseif(SIZEOF_LONG EQUAL 4)
    set(SIZE32 "long")
    set(USIZE32 "unsigned long")
else()
    set(SIZE32 "int32_t")
    set(USIZE32 "uint32_t")
endif()

# Configure speexdsp_config_types.h
# Ensure the target directory exists
file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/include/speex")
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/speexdsp_config_types.h.in"
    "${CMAKE_BINARY_DIR}/include/speex/speexdsp_config_types.h"
    @ONLY
)
add_compile_definitions(EXPORT= USE_KISS_FFT=1)

# Include directories
include_directories(
    ${CMAKE_SOURCE_DIR}/include
    ${CMAKE_SOURCE_DIR}/libspeexdsp
)

# Source files - exclude test files that contain main functions
file(GLOB speexdsp_SOURCES libspeexdsp/*.c)
list(REMOVE_ITEM speexdsp_SOURCES
    ${CMAKE_SOURCE_DIR}/libspeexdsp/testdenoise.c
    ${CMAKE_SOURCE_DIR}/libspeexdsp/testecho.c
    ${CMAKE_SOURCE_DIR}/libspeexdsp/testjitter.c
    ${CMAKE_SOURCE_DIR}/libspeexdsp/testresample.c
    ${CMAKE_SOURCE_DIR}/libspeexdsp/testresample2.c
)
add_library(speexdsp ${speexdsp_SOURCES})

# Installation rules
install(TARGETS speexdsp
    EXPORT speexdspConfig
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(DIRECTORY include/ DESTINATION include)
# Create and install pkg-config file
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/speexdsp.pc.in"
    "${CMAKE_BINARY_DIR}/speexdsp.pc"
    @ONLY
)
install(FILES "${CMAKE_BINARY_DIR}/speexdsp.pc"
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig
)

# Create config file
include(CMakePackageConfigHelpers)

configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/speexdspConfig.cmake.in"
    "${CMAKE_BINARY_DIR}/speexdspConfig.cmake"
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/speexdsp
)

write_basic_package_version_file(
    "${CMAKE_BINARY_DIR}/speexdspConfigVersion.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)

install(FILES
    "${CMAKE_BINARY_DIR}/speexdspConfig.cmake"
    "${CMAKE_BINARY_DIR}/speexdspConfigVersion.cmake"
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/speexdsp
)
