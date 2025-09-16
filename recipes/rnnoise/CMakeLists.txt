# RNNoise CMakeLists.txt for cross-platform builds
# This file is used by the conda-forge build system for CMake-based compilation
cmake_minimum_required(VERSION 3.15)
project(rnnoise VERSION 0.2 LANGUAGES C)

# Set C standard
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED ON)

# Check for model data files (downloaded or extracted)
message(STATUS "Checking for RNNoise model data files...")

# Check for extracted model files first (from official download)
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/rnnoise_data.h" AND
   EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/rnnoise_data.c")
    message(STATUS "Found extracted model data files in root - using downloaded model")
    set(HAS_MODEL_DATA TRUE)
    set(MODEL_DATA_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
elseif(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/src/rnnoise_data.h" AND
       EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/src/rnnoise_data.c")
    message(STATUS "Found model data files in src/ - using custom model")
    set(HAS_MODEL_DATA TRUE)
    set(MODEL_DATA_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src")
else()
    message(STATUS "Model data files not found - will use built-in default model")
    set(HAS_MODEL_DATA FALSE)
endif()

# Define core library sources (based on what's typically available)
set(CORE_SOURCES
    "src/denoise.c"
    "src/rnn.c"
    "src/pitch.c"
    "src/kiss_fft.c"
    "src/celt_lpc.c"
    "src/nnet.c"
    "src/nnet_default.c"
    "src/parse_lpcnet_weights.c"
)

# Add extracted table files if they exist
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/src/rnnoise_tables.c")
    list(APPEND CORE_SOURCES "src/rnnoise_tables.c")
endif()

# Add model data files only if they exist
if(HAS_MODEL_DATA)
    if(MODEL_DATA_DIR STREQUAL "${CMAKE_CURRENT_SOURCE_DIR}")
        # Model files are in root directory (extracted from download)
        list(APPEND CORE_SOURCES "rnnoise_data.c")
        # Copy header to build directory for inclusion
        configure_file("${CMAKE_CURRENT_SOURCE_DIR}/rnnoise_data.h"
                      "${CMAKE_CURRENT_BINARY_DIR}/rnnoise_data.h" COPYONLY)
    else()
        # Model files are in src directory
        list(APPEND CORE_SOURCES "src/rnnoise_data.c")
    endif()
endif()

# Filter to only include sources that actually exist
set(SOURCES)
foreach(source_file ${CORE_SOURCES})
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${source_file}")
        list(APPEND SOURCES ${source_file})
    else()
        message(STATUS "Skipping missing source: ${source_file}")
    endif()
endforeach()

message(STATUS "Using source files: ${SOURCES}")

# Verify we have the main header
if(NOT EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/include/rnnoise.h")
    message(FATAL_ERROR "Required header file missing: include/rnnoise.h")
endif()

# Create library
add_library(rnnoise SHARED ${SOURCES})

# Include directories
target_include_directories(rnnoise PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>)
target_include_directories(rnnoise PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_BINARY_DIR})

# Add model data directory if model files exist
if(HAS_MODEL_DATA AND MODEL_DATA_DIR STREQUAL "${CMAKE_CURRENT_SOURCE_DIR}")
    target_include_directories(rnnoise PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
endif()

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
            CUSTOM_ALLOC_DEFINED       # Prevent allocation function conflicts
            RNNOISE_ALLOC_DECLARED     # Mark allocation functions as declared
        )

        # MSVC compiler flags for better compatibility
        target_compile_options(rnnoise PRIVATE
            /W3              # Warning level 3
            /wd4244          # Disable conversion warnings (common in audio code)
            /wd4305          # Disable truncation warnings
            /wd4996          # Disable deprecated function warnings
            /DWIN32_LEAN_AND_MEAN  # Reduce Windows header conflicts
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

# Generate pkg-config file for Unix platforms
if(UNIX)
    # Create pkg-config file
    set(PKG_CONFIG_REQUIRES "")
    set(PKG_CONFIG_LIBDIR "\${libdir}")
    set(PKG_CONFIG_INCLUDEDIR "\${includedir}")
    set(PKG_CONFIG_LIBS "-L\${libdir} -lrnnoise")
    set(PKG_CONFIG_CFLAGS "-I\${includedir}")

    configure_file(
        "${CMAKE_CURRENT_LIST_DIR}/rnnoise.pc.in"
        "${CMAKE_CURRENT_BINARY_DIR}/rnnoise.pc"
        @ONLY
    )

    install(FILES "${CMAKE_CURRENT_BINARY_DIR}/rnnoise.pc"
        DESTINATION lib/pkgconfig
    )
endif()

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
