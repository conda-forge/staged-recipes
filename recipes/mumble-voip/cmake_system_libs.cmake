# CMake configuration for system library detection in mumble-voip
# This script helps mumble find system-installed libraries instead of bundled ones

# Set CMake policies for better find_package behavior
cmake_policy(SET CMP0074 NEW)  # Use <PackageName>_ROOT variables
if(POLICY CMP0144)
    cmake_policy(SET CMP0144 NEW)  # Use upper-case <PACKAGENAME>_ROOT variables
endif()
if(POLICY CMP0167)
    cmake_policy(SET CMP0167 NEW)  # Use modern FindBoost module
endif()

# Enable pkg-config support
find_package(PkgConfig QUIET)
if(NOT PkgConfig_FOUND)
    message(WARNING "PkgConfig not found - some system libraries may not be detected")
endif()

# Configure standard library search paths
if(CMAKE_PREFIX_PATH)
    list(APPEND CMAKE_MODULE_PATH "${CMAKE_PREFIX_PATH}/lib/cmake")
    list(APPEND CMAKE_MODULE_PATH "${CMAKE_PREFIX_PATH}/share/cmake")
endif()

# System library detection functions
function(find_system_library PACKAGE_NAME PKG_CONFIG_NAME)
    # Try find_package first
    find_package(${PACKAGE_NAME} QUIET)

    # Fall back to pkg-config if find_package fails and pkg-config is available
    if(NOT ${PACKAGE_NAME}_FOUND AND PkgConfig_FOUND)
        pkg_check_modules(${PACKAGE_NAME} QUIET ${PKG_CONFIG_NAME})
        if(${PACKAGE_NAME}_FOUND)
            message(STATUS "Found ${PACKAGE_NAME} via pkg-config: ${${PACKAGE_NAME}_VERSION}")
        else()
            message(STATUS "${PACKAGE_NAME} not found via pkg-config")
        endif()
    elseif(${PACKAGE_NAME}_FOUND)
        message(STATUS "Found ${PACKAGE_NAME} via find_package: ${${PACKAGE_NAME}_VERSION}")
    else()
        message(STATUS "${PACKAGE_NAME} not found")
    endif()
endfunction()

# Enhanced system library detection with alternative names
function(find_system_library_alt PACKAGE_NAME PKG_CONFIG_NAME ALT_PKG_CONFIG_NAME)
    find_system_library(${PACKAGE_NAME} ${PKG_CONFIG_NAME})

    # Try alternative pkg-config name if first attempt failed
    if(NOT ${PACKAGE_NAME}_FOUND AND PkgConfig_FOUND AND ALT_PKG_CONFIG_NAME)
        pkg_check_modules(${PACKAGE_NAME} QUIET ${ALT_PKG_CONFIG_NAME})
        if(${PACKAGE_NAME}_FOUND)
            message(STATUS "Found ${PACKAGE_NAME} via pkg-config (alt name): ${${PACKAGE_NAME}_VERSION}")
        endif()
    endif()
endfunction()

# Audio libraries with alternative package names
# Use pkg-config only for audio libraries to avoid CMake find_package issues
if(PkgConfig_FOUND)
    pkg_check_modules(Opus QUIET opus)
    if(Opus_FOUND)
        message(STATUS "Found Opus via pkg-config: ${Opus_VERSION}")
    endif()

    pkg_check_modules(Ogg QUIET ogg)
    if(Ogg_FOUND)
        message(STATUS "Found Ogg via pkg-config: ${Ogg_VERSION}")
    endif()

    pkg_check_modules(SndFile QUIET sndfile)
    if(SndFile_FOUND)
        message(STATUS "Found SndFile via pkg-config: ${SndFile_VERSION}")
    endif()

    pkg_check_modules(FLAC QUIET flac)
    if(FLAC_FOUND)
        message(STATUS "Found FLAC via pkg-config: ${FLAC_VERSION}")
    endif()

    pkg_check_modules(Vorbis QUIET vorbis)
    if(Vorbis_FOUND)
        message(STATUS "Found Vorbis via pkg-config: ${Vorbis_VERSION}")
    endif()

    # SpeexDSP is not available in conda-forge for Linux, use bundled version
    pkg_check_modules(SpeexDSP QUIET speexdsp)
    if(SpeexDSP_FOUND)
        message(STATUS "Found SpeexDSP via pkg-config: ${SpeexDSP_VERSION}")
    else()
        message(STATUS "SpeexDSP not found - will use bundled version")
    endif()
else()
    message(STATUS "PkgConfig not found - audio libraries will use bundled versions")
endif()

# Database library - use pkg-config to avoid CMake issues
if(PkgConfig_FOUND)
    pkg_check_modules(SOCI QUIET soci)
    if(SOCI_FOUND)
        message(STATUS "Found SOCI via pkg-config: ${SOCI_VERSION}")
    endif()
endif()

# Platform-specific libraries
if(UNIX AND NOT APPLE)
    # Linux-specific libraries
    find_system_library(ALSA alsa)
    find_system_library(Avahi avahi-client)
    find_system_library(X11 x11)

    # Additional X11 components
    find_package(X11 QUIET COMPONENTS Xext Xi)

elseif(APPLE)
    # macOS-specific frameworks
    find_library(COREAUDIO_FRAMEWORK CoreAudio)
    find_library(AUDIOUNIT_FRAMEWORK AudioUnit)
    find_library(AUDIOTOOLBOX_FRAMEWORK AudioToolbox)

elseif(WIN32)
    # Windows-specific libraries are typically found automatically
    # but we can set hints if needed
    if(CMAKE_PREFIX_PATH)
        list(APPEND CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}/Library")
    endif()
endif()

# Utility libraries that should use system versions
find_package(nlohmann_json QUIET)
find_package(spdlog QUIET)
find_package(utf8cpp QUIET)

# Boost (required by mumble) - use new BoostConfig.cmake if available
if(CMAKE_VERSION VERSION_GREATER_EQUAL "3.30")
    find_package(Boost QUIET CONFIG COMPONENTS system thread)
    if(NOT Boost_FOUND)
        # Fallback to traditional FindBoost module
        find_package(Boost QUIET MODULE COMPONENTS system thread)
    endif()
else()
    find_package(Boost QUIET COMPONENTS system thread)
endif()

# Protobuf - enhanced detection for conda-forge
find_package(Protobuf QUIET)
if(NOT Protobuf_FOUND)
    # Try with explicit path hints for conda-forge
    if(DEFINED ENV{PREFIX})
        set(Protobuf_ROOT "$ENV{PREFIX}")
        find_package(Protobuf QUIET CONFIG PATHS "$ENV{PREFIX}/lib/cmake/protobuf" NO_DEFAULT_PATH)
        if(NOT Protobuf_FOUND)
            find_package(Protobuf QUIET MODULE)
        endif()
    endif()
endif()

# OpenSSL
find_package(OpenSSL QUIET)

# Qt
find_package(Qt5 QUIET COMPONENTS Core)

# Poco
find_package(Poco QUIET COMPONENTS Foundation Net)

# Tracy profiler (optional)
find_package(Tracy QUIET)
if(Tracy_FOUND)
    message(STATUS "Found Tracy profiler - enabling profiling support")
    set(USE_TRACY ON)
else()
    message(STATUS "Tracy profiler not found - disabling profiling support")
    set(USE_TRACY OFF)
endif()

# Summary of system library detection
message(STATUS "=== System Library Detection Summary ===")
message(STATUS "Audio Libraries:")
message(STATUS "  Opus: ${Opus_FOUND}")
message(STATUS "  Ogg: ${Ogg_FOUND}")
message(STATUS "  SndFile: ${SndFile_FOUND}")
message(STATUS "  FLAC: ${FLAC_FOUND}")
message(STATUS "  Vorbis: ${Vorbis_FOUND}")
message(STATUS "  SpeexDSP: ${SpeexDSP_FOUND} (bundled if not found)")
message(STATUS "Core Libraries:")
message(STATUS "  SOCI: ${SOCI_FOUND}")
message(STATUS "  nlohmann_json: ${nlohmann_json_FOUND}")
message(STATUS "  spdlog: ${spdlog_FOUND}")
message(STATUS "  utf8cpp: ${utf8cpp_FOUND}")
message(STATUS "  Boost: ${Boost_FOUND}")
message(STATUS "  Protobuf: ${Protobuf_FOUND}")
message(STATUS "  OpenSSL: ${OpenSSL_FOUND}")
message(STATUS "  Qt5: ${Qt5_FOUND}")
message(STATUS "  Poco: ${Poco_FOUND}")
message(STATUS "  Tracy: ${Tracy_FOUND}")

if(UNIX AND NOT APPLE)
    message(STATUS "ALSA: ${ALSA_FOUND}")
    message(STATUS "Avahi: ${Avahi_FOUND}")
    message(STATUS "X11: ${X11_FOUND}")
endif()

message(STATUS "========================================")

# Validate critical dependencies only when running in actual build context
if(CMAKE_SOURCE_DIR)
    set(CRITICAL_DEPS "Boost;Protobuf;OpenSSL;Qt5;Poco")
    foreach(DEP ${CRITICAL_DEPS})
        if(NOT ${DEP}_FOUND)
            message(WARNING "Critical dependency ${DEP} not found - this may cause build failures")
        endif()
    endforeach()
endif()

# Set compiler definitions for bundled vs system libraries
if(Opus_FOUND)
    add_compile_definitions(USE_SYSTEM_OPUS)
endif()

if(Ogg_FOUND)
    add_compile_definitions(USE_SYSTEM_OGG)
endif()

if(SndFile_FOUND)
    add_compile_definitions(USE_SYSTEM_SNDFILE)
endif()

if(SOCI_FOUND)
    add_compile_definitions(USE_SYSTEM_SOCI)
endif()

if(SpeexDSP_FOUND)
    add_compile_definitions(USE_SYSTEM_SPEEXDSP)
else()
    message(STATUS "Using bundled SpeexDSP (conda-forge package not available on this platform)")
endif()

if(Tracy_FOUND)
    add_compile_definitions(USE_SYSTEM_TRACY)
endif()

# Always use system versions of these (they're required dependencies)
add_compile_definitions(USE_SYSTEM_JSON)
add_compile_definitions(USE_SYSTEM_SPDLOG)
add_compile_definitions(USE_SYSTEM_UTF8CPP)
