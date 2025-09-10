# RNNoise CMakeLists.txt for Windows builds
# This file is used by the conda-forge build system for cross-platform compilation
cmake_minimum_required(VERSION 3.15)
project(rnnoise VERSION 0.2 LANGUAGES C)

# Set C standard
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Ensure required source files exist - create placeholders if needed
message(STATUS "Checking for required RNNoise source files...")

# Check for model data header
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/src/rnnoise_data.h")
    message(STATUS "Found rnnoise_data.h")
else()
    message(STATUS "Creating placeholder rnnoise_data.h (model data not downloaded)")
    file(WRITE "${CMAKE_CURRENT_SOURCE_DIR}/src/rnnoise_data.h"
        "#ifndef RNNOISE_DATA_H\n"
        "#define RNNOISE_DATA_H\n"
        "/* Placeholder header - model data not available */\n"
        "/* This will use built-in fallback model */\n"
        "#endif\n")
endif()

# Check for model data implementation
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/src/rnnoise_data.c")
    message(STATUS "Found rnnoise_data.c")
else()
    message(STATUS "Creating placeholder rnnoise_data.c (model data not downloaded)")
    file(WRITE "${CMAKE_CURRENT_SOURCE_DIR}/src/rnnoise_data.c"
        "/* Placeholder implementation - model data not available */\n"
        "/* RNNoise will fall back to built-in default model */\n")
endif()

# Check for os_support.h (needed by vec.h when no SIMD optimizations are used)
if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/src/os_support.h")
    message(STATUS "Creating minimal os_support.h stub")
    file(WRITE "${CMAKE_CURRENT_SOURCE_DIR}/src/os_support.h"
        "#ifndef OS_SUPPORT_H\n"
        "#define OS_SUPPORT_H\n"
        "\n"
        "#include <string.h>\n"
        "#include <stdlib.h>\n"
        "#include \"opus_types.h\"\n"
        "\n"
        "/* Minimal OS support macros for RNNoise */\n"
        "#define OPUS_CLEAR(dst, n) (memset((dst), 0, (n)*sizeof(*(dst))))\n"
        "#define OPUS_COPY(dst, src, n) (memcpy((dst), (src), (n)*sizeof(*(dst)) + 0*((dst)-(src))))\n"
        "#define OPUS_MOVE(dst, src, n) (memmove((dst), (src), (n)*sizeof(*(dst)) + 0*((dst)-(src))))\n"
        "\n"
        "#endif /* OS_SUPPORT_H */\n")
endif()

# Verify core source files exist
set(REQUIRED_FILES
    "src/denoise.c"
    "src/rnn.c"
    "src/pitch.c"
    "src/kiss_fft.c"
    "src/celt_lpc.c"
    "include/rnnoise.h"
)

foreach(file ${REQUIRED_FILES})
    if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${file}")
        message(FATAL_ERROR "Required source file missing: ${file}")
    endif()
endforeach()

# Core library sources (from Makefile.am)
set(SOURCES
    "src/denoise.c"
    "src/rnn.c"
    "src/pitch.c"
    "src/kiss_fft.c"
    "src/celt_lpc.c"
    "src/nnet.c"
    "src/nnet_default.c"
    "src/parse_lpcnet_weights.c"
    "src/rnnoise_data.c"
    "src/rnnoise_tables.c"
)

# Create library
add_library(rnnoise SHARED ${SOURCES})

# Include directories
target_include_directories(rnnoise PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>)
target_include_directories(rnnoise PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src)

# Platform-specific configurations
if(WIN32)
    # Windows-specific definitions
    target_compile_definitions(rnnoise PRIVATE
        WIN32
        _WINDOWS
    )

    # MSVC-specific flags
    if(MSVC)
        target_compile_definitions(rnnoise PRIVATE
            _USE_MATH_DEFINES          # Enable M_PI and other math constants
            _CRT_SECURE_NO_WARNINGS    # Suppress MSVC security warnings
            "M_PI=3.14159265358979323846"  # Define M_PI explicitly as fallback
        )

        # MSVC compiler flags for better compatibility
        target_compile_options(rnnoise PRIVATE
            /W3              # Warning level 3
            /wd4244          # Disable conversion warnings (common in audio code)
            /wd4305          # Disable truncation warnings
        )
    endif()
endif()

# Unix/Linux configurations
if(UNIX)
    # Link math library (required for libm functions)
    target_link_libraries(rnnoise PRIVATE m)

    # Set proper SONAME for shared library
    set_target_properties(rnnoise PROPERTIES
        VERSION 0.4.1
        SOVERSION 0
    )
endif()

# Installation configuration
install(TARGETS rnnoise
    EXPORT rnnoise-targets
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

# Install headers
install(FILES "include/rnnoise.h"
    DESTINATION include
)

# Install export targets (for find_package support)
install(EXPORT rnnoise-targets
    FILE rnnoise-targets.cmake
    NAMESPACE rnnoise::
    DESTINATION lib/cmake/rnnoise
)

# Create and install package configuration files
include(CMakePackageConfigHelpers)

# Generate config files if template exists
if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/rnnoise-config.cmake.in")
    # Generate config file
    configure_package_config_file(
        "${CMAKE_CURRENT_LIST_DIR}/rnnoise-config.cmake.in"
        "${CMAKE_CURRENT_BINARY_DIR}/rnnoise-config.cmake"
        INSTALL_DESTINATION lib/cmake/rnnoise
        NO_SET_AND_CHECK_MACRO
    )

    # Generate version file
    write_basic_package_version_file(
        "${CMAKE_CURRENT_BINARY_DIR}/rnnoise-config-version.cmake"
        VERSION ${PROJECT_VERSION}
        COMPATIBILITY SameMajorVersion
    )

    # Install config files
    install(FILES
        "${CMAKE_CURRENT_BINARY_DIR}/rnnoise-config.cmake"
        "${CMAKE_CURRENT_BINARY_DIR}/rnnoise-config-version.cmake"
        DESTINATION lib/cmake/rnnoise
    )
else()
    message(STATUS "Package config template not found - skipping CMake config generation")
endif()
