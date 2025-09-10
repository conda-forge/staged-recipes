# CMakeLists.txt for SpeexDSP - Windows/MSVC build support
# This is a conda-forge compatible CMake configuration for building SpeexDSP on Windows
# with Visual Studio Build Tools (MSVC) instead of MSYS2/autotools.

cmake_minimum_required(VERSION 3.15)

project(SpeexDSP
    VERSION 1.2.1
    DESCRIPTION "SpeexDSP audio processing library"
    LANGUAGES C
)

# Set C standard
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Configuration options
option(ENABLE_FIXED_POINT "Enable fixed-point arithmetic" OFF)
option(ENABLE_FLOAT_API "Enable floating-point API" ON)
option(ENABLE_SSE "Enable SSE optimizations" ON)
option(ENABLE_NEON "Enable NEON optimizations" OFF)
option(DISABLE_VBR "Disable variable bitrate" OFF)
option(BUILD_SHARED_LIBS "Build shared libraries" ON)
option(BUILD_EXAMPLES "Build example programs" OFF)

# Check for standard headers
include(CheckIncludeFile)
check_include_file(stdint.h HAVE_STDINT_H)
check_include_file(inttypes.h HAVE_INTTYPES_H)
check_include_file(memory.h HAVE_MEMORY_H)
check_include_file(stdlib.h HAVE_STDLIB_H)
check_include_file(string.h HAVE_STRING_H)
check_include_file(strings.h HAVE_STRINGS_H)
check_include_file(sys/stat.h HAVE_SYS_STAT_H)
check_include_file(sys/types.h HAVE_SYS_TYPES_H)
check_include_file(unistd.h HAVE_UNISTD_H)

# Platform detection
if(WIN32)
    set(OS_SUPPORT_FILES)
    if(MSVC)
        add_compile_definitions(_CRT_SECURE_NO_WARNINGS)
        add_compile_definitions(_USE_MATH_DEFINES)
        add_compile_definitions(HAVE_CONFIG_H)
        add_compile_definitions(USE_KISS_FFT)
        add_compile_definitions(HAVE_KISS_FFT)
    endif()
elseif(APPLE)
    set(OS_SUPPORT_FILES)
else()
    set(OS_SUPPORT_FILES)
endif()

# Configure config.h equivalent
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/config.h.in"
    "${CMAKE_BINARY_DIR}/config.h"
    @ONLY
)

# Configure speexdsp_config_types.h
# Ensure the target directory exists
file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/include/speex")
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/speexdsp_config_types.h.in"
    "${CMAKE_BINARY_DIR}/include/speex/speexdsp_config_types.h"
    @ONLY
)

# Global compile definitions for all platforms
add_compile_definitions(HAVE_CONFIG_H)
add_compile_definitions(USE_KISS_FFT)
add_compile_definitions(HAVE_KISS_FFT)

# Include directories
include_directories(
    "${CMAKE_CURRENT_SOURCE_DIR}/include"
    "${CMAKE_CURRENT_SOURCE_DIR}/libspeexdsp"
    "${CMAKE_BINARY_DIR}"
    "${CMAKE_BINARY_DIR}/include"
)

# Source files
set(SPEEXDSP_SOURCES
    libspeexdsp/preprocess.c
    libspeexdsp/jitter.c
    libspeexdsp/mdf.c
    libspeexdsp/fftwrap.c
    libspeexdsp/filterbank.c
    libspeexdsp/resample.c
    libspeexdsp/buffer.c
    libspeexdsp/scal.c
    libspeexdsp/smallft.c
    libspeexdsp/kiss_fft.c
    libspeexdsp/kiss_fftr.c
)

# SSE optimizations
if(ENABLE_SSE AND (CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64|AMD64|i386|i686"))
    list(APPEND SPEEXDSP_SOURCES libspeexdsp/resample_sse.h)
    if(MSVC)
        add_compile_options(/arch:SSE2)
    else()
        add_compile_options(-msse2)
    endif()
    add_compile_definitions(USE_SSE)
    add_compile_definitions(_USE_SSE)
endif()

# NEON optimizations
if(ENABLE_NEON AND CMAKE_SYSTEM_PROCESSOR MATCHES "arm|aarch64")
    add_compile_definitions(USE_NEON)
endif()

# Fixed-point vs floating-point
if(ENABLE_FIXED_POINT)
    add_compile_definitions(FIXED_POINT)
else()
    add_compile_definitions(FLOATING_POINT)
endif()

if(NOT ENABLE_FLOAT_API)
    add_compile_definitions(DISABLE_FLOAT_API)
endif()

if(DISABLE_VBR)
    add_compile_definitions(DISABLE_VBR)
endif()

# Additional Windows-specific definitions for math support
if(WIN32 AND MSVC)
    add_compile_definitions(HAVE_MATH_H)
    add_compile_definitions(inline=__inline)
endif()

# Export symbols on Windows
if(WIN32 AND BUILD_SHARED_LIBS)
    # Use empty EXPORT macro to avoid linkage conflicts
    add_compile_definitions(EXPORT=)
else()
    add_compile_definitions(EXPORT=)
endif()

# Create the main library
add_library(speexdsp ${SPEEXDSP_SOURCES})

# Set library properties
set_target_properties(speexdsp PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION 1
    PUBLIC_HEADER "include/speex/speex_preprocess.h;include/speex/speex_echo.h;include/speex/speex_jitter.h;include/speex/speex_resampler.h;include/speex/speexdsp_types.h"
)

# Windows-specific properties for DLL export
if(WIN32 AND BUILD_SHARED_LIBS)
    set_target_properties(speexdsp PROPERTIES
        WINDOWS_EXPORT_ALL_SYMBOLS ON
    )
endif()

# Platform-specific libraries
if(WIN32)
    target_link_libraries(speexdsp PRIVATE winmm)
endif()

if(UNIX AND NOT APPLE)
    target_link_libraries(speexdsp PRIVATE m)
endif()

# Compiler-specific flags
if(MSVC)
    target_compile_options(speexdsp PRIVATE
        /W3
        /wd4244 /wd4305  # Suppress common conversion warnings in legacy code
    )
else()
    target_compile_options(speexdsp PRIVATE
        -Wall -Wextra -Wno-unused-parameter
    )
endif()

# Examples (disabled by default for conda builds)
if(BUILD_EXAMPLES)
    # Add example targets here if needed
    message(STATUS "Examples are disabled for conda builds")
endif()

# Install configuration
include(GNUInstallDirs)

# Windows conda packages install to Library subdirectory
if(WIN32)
    set(CMAKE_INSTALL_LIBDIR "lib")
    set(CMAKE_INSTALL_INCLUDEDIR "include")
    set(CMAKE_INSTALL_BINDIR "bin")
endif()

# Install the library
install(TARGETS speexdsp
    EXPORT SpeexDSPTargets
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/speex
)

# Install additional headers
install(DIRECTORY include/speex/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/speex
    FILES_MATCHING PATTERN "*.h"
    PATTERN "speexdsp_config_types.h" EXCLUDE
)

# Install generated headers
install(FILES "${CMAKE_BINARY_DIR}/include/speex/speexdsp_config_types.h"
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/speex
)

# Create and install pkg-config file
if(NOT WIN32)
    configure_file(
        "${CMAKE_CURRENT_SOURCE_DIR}/cmake/speexdsp.pc.in"
        "${CMAKE_BINARY_DIR}/speexdsp.pc"
        @ONLY
    )
    install(FILES "${CMAKE_BINARY_DIR}/speexdsp.pc"
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig
    )
endif()

# Export configuration
install(EXPORT SpeexDSPTargets
    FILE SpeexDSPTargets.cmake
    NAMESPACE SpeexDSP::
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/SpeexDSP
)

# Create config file
include(CMakePackageConfigHelpers)

configure_package_config_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/cmake/SpeexDSPConfig.cmake.in"
    "${CMAKE_BINARY_DIR}/SpeexDSPConfig.cmake"
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/SpeexDSP
)

write_basic_package_version_file(
    "${CMAKE_BINARY_DIR}/SpeexDSPConfigVersion.cmake"
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)

install(FILES
    "${CMAKE_BINARY_DIR}/SpeexDSPConfig.cmake"
    "${CMAKE_BINARY_DIR}/SpeexDSPConfigVersion.cmake"
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/SpeexDSP
)

# Summary
message(STATUS "SpeexDSP Configuration Summary:")
message(STATUS "  Version: ${PROJECT_VERSION}")
message(STATUS "  Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "  Shared libraries: ${BUILD_SHARED_LIBS}")
message(STATUS "  Fixed-point: ${ENABLE_FIXED_POINT}")
message(STATUS "  Float API: ${ENABLE_FLOAT_API}")
message(STATUS "  SSE: ${ENABLE_SSE}")
message(STATUS "  NEON: ${ENABLE_NEON}")
message(STATUS "  Install prefix: ${CMAKE_INSTALL_PREFIX}")
