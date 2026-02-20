#!/usr/bin/env nu

# Mumble VoIP Server nushell build script
# Builds the mumble-server package with conda-forge dependencies

def main [] {
    print "Building Mumble VoIP server..."

    # Navigate to mumble source directory
    cd src/mumble

    # Build server
    mut cmake_args = [
        "-B" "build"
        "-G" "Ninja"
        "-DCMAKE_BUILD_TYPE=Release"
        "-DCMAKE_CXX_STANDARD=20"
        "-DCMAKE_CXX_STANDARD_REQUIRED=ON"
        # "-Dspeechd=OFF"
        "-Doverlay=OFF"
        # "-Doverlay-xcompile=OFF"
        "-Dzeroconf=OFF"
        "-Dice=OFF"
        "-Dtracy=OFF"
        "-Dclient=OFF"
        "-Dserver=ON"
        $"-DCMAKE_PREFIX_PATH=($env.PREFIX)"
        # $"-DBOOST_ROOT=($env.PREFIX)"
        $"-DCMAKE_INSTALL_PREFIX=($env.PREFIX)"
        $"-DCMAKE_INSTALL_LIBDIR=($env.PREFIX)/lib"
        $"-DCMAKE_INSTALL_BINDIR=($env.PREFIX)/bin"
        $"-DCMAKE_INSTALL_INCLUDEDIR=($env.PREFIX)/include"
        "-DMUMBLE_INSTALL_LIBDIR=lib/mumble"
        "-DMUMBLE_INSTALL_PLUGINDIR=lib/mumble/plugins"
        $"-DCMAKE_INCLUDE_PATH=($env.PREFIX)/include"
        "-DCMAKE_BUILD_WITH_INSTALL_RPATH=ON"
        "-DCMAKE_INSTALL_RPATH_USE_LINK_PATH=ON"
        $"-DCMAKE_INSTALL_RPATH=($env.PREFIX)/lib"
        # Use conda-forge toolchain
        "--toolchain" "conda_toolchain.cmake"
        # Force use of system packages instead of bundled ones
        "-Dbundled-json=OFF"
        "-Dbundled-spdlog=OFF"
        "-Dbundled-utf8cpp=OFF"
        "-Dbundled-opus=OFF"
        "-Dbundled-ogg=OFF"
        "-Dbundled-sndfile=OFF"
        "-Dbundled-flac=OFF"
        "-Dbundled-vorbis=OFF"
        "-Dbundled-speexdsp=OFF"
        "-Dbundled-tracy=OFF"
        "-Dbundled-soci=OFF"
        "-Dbundled-gsl=OFF"
        "-DTRACY_ENABLE=OFF"
    ]

    # Add platform-specific arguments
    match ($nu.os-info.name) {
        "linux" => {
            # Set up environment for library detection
            $env.PKG_CONFIG_PATH = $"($env.PREFIX)/lib/pkgconfig:($env.PKG_CONFIG_PATH | default '')"
            $env.CMAKE_PREFIX_PATH = $"($env.PREFIX):($env.CMAKE_PREFIX_PATH | default '')"
            $env.CPPFLAGS = $"-I($env.PREFIX)/include ($env.CPPFLAGS | default '')"
            $env.LDFLAGS = $"-L($env.PREFIX)/lib ($env.LDFLAGS | default '')"

            $cmake_args = ($cmake_args | append [
                "-DCMAKE_CXX_FLAGS=-Wno-error=cpp -Wno-cpp -Wno-deprecated-declarations -Wno-error=unused-parameter -Wno-error=conversion"
                "-DCMAKE_C_FLAGS=-Wno-error=cpp -Wno-cpp -std=c11 -Wno-error=unused-parameter -Wno-error=conversion"
                # Linux-specific system library paths
                $"-DOpus_ROOT=($env.PREFIX)"
                $"-DOgg_ROOT=($env.PREFIX)"
                $"-DSndFile_ROOT=($env.PREFIX)"
                $"-DSpeexDSP_ROOT=($env.PREFIX)"
                $"-DALSA_ROOT=($env.PREFIX)"
                $"-DProtobuf_ROOT=($env.PREFIX)"
                $"-DProtobuf_DIR=($env.PREFIX)/lib/cmake/protobuf"
                "-DUSE_ALSA=ON"
            ])
        }
        "macos" => {
            # Use conda-forge recommended approach for C++ availability
            # MACOSX_SDK_VERSION is set in variants.yaml, let conda handle deployment target
            $cmake_args = ($cmake_args | append [
                "-DCMAKE_CXX_FLAGS=-Wno-deprecated-declarations -D_LIBCPP_DISABLE_AVAILABILITY"
                "-DCMAKE_C_FLAGS=-Wno-deprecated-declarations -std=c11"
                # macOS-specific system library paths
                $"-DOpus_ROOT=($env.PREFIX)"
                $"-DOgg_ROOT=($env.PREFIX)"
                $"-DSndFile_ROOT=($env.PREFIX)"
                $"-DSpeexDSP_ROOT=($env.PREFIX)"
                $"-DProtobuf_ROOT=($env.PREFIX)"
                $"-DProtobuf_DIR=($env.PREFIX)/lib/cmake/protobuf"
                $"-DSOCI_ROOT=($env.PREFIX)"
            ])
        }
        "windows" => {
            $cmake_args = ($cmake_args | append [
                "-DCMAKE_CXX_FLAGS=/EHsc /DWIN32 /wd4996"
                "-DCMAKE_C_FLAGS=/std:c11 /EHsc /DWIN32 /wd4996"
                "-DCMAKE_CXX_FLAGS_RELEASE=/MD /O2 /DNDEBUG"
                "-DCMAKE_C_FLAGS_RELEASE=/MD /O2 /DNDEBUG"
                "-DCMAKE_CXX_FLAGS_DEBUG=/MDd /Od /Zi /RTC1"
                "-DCMAKE_C_FLAGS_DEBUG=/MDd /Od /Zi /RTC1"
                "-DCMAKE_EXE_LINKER_FLAGS=/DEFAULTLIB:ws2_32.lib /DEFAULTLIB:crypt32.lib"
                $"-DQt5_DIR=($env.PREFIX)/Library/lib/cmake/Qt5"
                # Windows-specific system library paths
                $"-DOpus_ROOT=($env.PREFIX)/Library"
                $"-DOgg_ROOT=($env.PREFIX)/Library"
                $"-DSndFile_ROOT=($env.PREFIX)/Library"
                $"-DSpeexDSP_ROOT=($env.PREFIX)/Library"
                $"-DProtobuf_ROOT=($env.PREFIX)/Library"
                $"-DProtobuf_DIR=($env.PREFIX)/Library/lib/cmake/protobuf"
                $"-DSOCI_ROOT=($env.PREFIX)/Library"
            ])
        }
    }

    # Copy CMake configuration files
    print "Copying CMake configuration files..."

    # Debug: Show current directory structure
    print $"Current working directory: (pwd)"
    print $"SRC_DIR environment variable: ($env.SRC_DIR? | default 'not set')"
    print $"RECIPE_DIR environment variable: ($env.RECIPE_DIR? | default 'not set')"
    print "Directory contents:"
    try {
        ls | each { |item| print $"  ($item.name)" }
    } catch {
        print "  Could not list directory contents"
    }

    if ($env.SRC_DIR? | is-not-empty) {
        print $"SRC_DIR contents:"
        try {
            ls $env.SRC_DIR | each { |item| print $"  ($item.name)" }
        } catch {
            print "  Could not list SRC_DIR contents"
        }
    }

    # Try multiple possible locations for the CMake files
    let cmake_locations = [
        $"($env.SRC_DIR)/cmake-config/cmake_system_libs.cmake"  # From source config directory
        "../../cmake_system_libs.cmake"      # Original expected location
        "../cmake_system_libs.cmake"         # One level up
        "cmake_system_libs.cmake"            # Current directory
        $"($env.RECIPE_DIR)/cmake_system_libs.cmake"  # Recipe directory
    ]

    let toolchain_locations = [
        $"($env.SRC_DIR)/cmake-config/conda_toolchain.cmake"    # From source config directory
        "../../conda_toolchain.cmake"
        "../conda_toolchain.cmake"
        "conda_toolchain.cmake"
        $"($env.RECIPE_DIR)/conda_toolchain.cmake"
    ]

    mut cmake_found = false
    mut toolchain_found = false

    # Find cmake_system_libs.cmake
    for location in $cmake_locations {
        if ($location | path exists) {
            cp $location cmake_system_libs.cmake
            print $"✓ Found cmake_system_libs.cmake at: ($location)"
            $cmake_found = true
            break
        }
    }

    # Find conda_toolchain.cmake
    for location in $toolchain_locations {
        if ($location | path exists) {
            cp $location conda_toolchain.cmake
            print $"✓ Found conda_toolchain.cmake at: ($location)"
            $toolchain_found = true
            break
        }
    }

    if not $cmake_found {
        print "⚠ CMake configuration files not found, creating them directly..."

        # Create a minimal cmake_system_libs.cmake that will be included after project()
        let cmake_content = '# CMake configuration for system library detection in mumble-voip
# This file is included after project() to avoid language issues

message(STATUS "Loading mumble system library configuration...")

# Enable pkg-config for audio libraries
find_package(PkgConfig QUIET)

if(PkgConfig_FOUND)
    # Find audio libraries via pkg-config
    pkg_check_modules(Opus QUIET opus)
    if(Opus_FOUND)
        message(STATUS "Found Opus via pkg-config: ${Opus_VERSION}")
        add_compile_definitions(USE_SYSTEM_OPUS)
    endif()

    pkg_check_modules(Ogg QUIET ogg)
    if(Ogg_FOUND)
        message(STATUS "Found Ogg via pkg-config: ${Ogg_VERSION}")
        add_compile_definitions(USE_SYSTEM_OGG)
    endif()

    pkg_check_modules(SndFile QUIET sndfile)
    if(SndFile_FOUND)
        message(STATUS "Found SndFile via pkg-config: ${SndFile_VERSION}")
        add_compile_definitions(USE_SYSTEM_SNDFILE)
    endif()

    pkg_check_modules(FLAC QUIET flac)
    if(FLAC_FOUND)
        message(STATUS "Found FLAC via pkg-config: ${FLAC_VERSION}")
    endif()

    pkg_check_modules(Vorbis QUIET vorbis)
    if(Vorbis_FOUND)
        message(STATUS "Found Vorbis via pkg-config: ${Vorbis_VERSION}")
    endif()
endif()

# Always use system versions of these
add_compile_definitions(USE_SYSTEM_JSON)
add_compile_definitions(USE_SYSTEM_SPDLOG)
add_compile_definitions(USE_SYSTEM_UTF8CPP)

message(STATUS "System library configuration loaded")
'

        $cmake_content | save cmake_system_libs.cmake
        print "✓ Created minimal cmake_system_libs.cmake"
        $cmake_found = true
    }

    if not $toolchain_found {
        # Create conda_toolchain.cmake directly
        let toolchain_content = '# CMake toolchain file for conda-forge integration
# This file ensures proper detection and linking of conda-forge packages

# Set the system name
set(CMAKE_SYSTEM_NAME ${CMAKE_HOST_SYSTEM_NAME})

# Use conda-forge environment variables
if(DEFINED ENV{PREFIX})
    set(CMAKE_PREFIX_PATH "$ENV{PREFIX}" ${CMAKE_PREFIX_PATH})
    set(CMAKE_FIND_ROOT_PATH "$ENV{PREFIX}")

    # Set standard paths
    list(APPEND CMAKE_PREFIX_PATH "$ENV{PREFIX}")
    list(APPEND CMAKE_PREFIX_PATH "$ENV{PREFIX}/lib/cmake")
    list(APPEND CMAKE_PREFIX_PATH "$ENV{PREFIX}/share/cmake")
    list(APPEND CMAKE_PREFIX_PATH "$ENV{PREFIX}/lib/pkgconfig")

    # Platform-specific paths
    if(WIN32)
        list(APPEND CMAKE_PREFIX_PATH "$ENV{PREFIX}/Library")
        list(APPEND CMAKE_PREFIX_PATH "$ENV{PREFIX}/Library/lib/cmake")
        list(APPEND CMAKE_PREFIX_PATH "$ENV{PREFIX}/Library/share/cmake")
    endif()

    message(STATUS "Conda environment detected: $ENV{PREFIX}")
else()
    message(WARNING "PREFIX environment variable not set - conda-forge integration may not work properly")
endif()

# Set pkg-config path
if(DEFINED ENV{PREFIX})
    if(WIN32)
        if(DEFINED ENV{PKG_CONFIG_PATH})
            set(ENV{PKG_CONFIG_PATH} "$ENV{PREFIX}/Library/lib/pkgconfig:$ENV{PKG_CONFIG_PATH}")
        else()
            set(ENV{PKG_CONFIG_PATH} "$ENV{PREFIX}/Library/lib/pkgconfig")
        endif()
    else()
        if(DEFINED ENV{PKG_CONFIG_PATH})
            set(ENV{PKG_CONFIG_PATH} "$ENV{PREFIX}/lib/pkgconfig:$ENV{PKG_CONFIG_PATH}")
        else()
            set(ENV{PKG_CONFIG_PATH} "$ENV{PREFIX}/lib/pkgconfig")
        endif()
    endif()
endif()

# Configure find modes for conda-forge
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# Prefer conda-forge packages over system packages
set(CMAKE_FIND_PACKAGE_PREFER_CONFIG ON)

# Enable pkg-config
find_package(PkgConfig QUIET)
if(NOT PkgConfig_FOUND)
    message(STATUS "PkgConfig not found - some system libraries may not be detected")
endif()

# Set compiler and linker flags for conda-forge
if(DEFINED ENV{PREFIX})
    if(NOT WIN32)
        set(CMAKE_C_FLAGS_INIT "-I$ENV{PREFIX}/include")
        set(CMAKE_CXX_FLAGS_INIT "-I$ENV{PREFIX}/include")
        set(CMAKE_EXE_LINKER_FLAGS_INIT "-L$ENV{PREFIX}/lib")
        set(CMAKE_SHARED_LINKER_FLAGS_INIT "-L$ENV{PREFIX}/lib")
    else()
        set(CMAKE_C_FLAGS_INIT "/I$ENV{PREFIX}/Library/include")
        set(CMAKE_CXX_FLAGS_INIT "/I$ENV{PREFIX}/Library/include")
        set(CMAKE_EXE_LINKER_FLAGS_INIT "/LIBPATH:$ENV{PREFIX}/Library/lib")
        set(CMAKE_SHARED_LINKER_FLAGS_INIT "/LIBPATH:$ENV{PREFIX}/Library/lib")
    endif()
endif()

# Platform-specific configuration
if(APPLE)
    # macOS-specific conda-forge integration
    if(DEFINED ENV{PREFIX})
        set(CMAKE_OSX_SYSROOT "$ENV{CONDA_BUILD_SYSROOT}")
        if(DEFINED ENV{MACOSX_DEPLOYMENT_TARGET})
            set(CMAKE_OSX_DEPLOYMENT_TARGET "$ENV{MACOSX_DEPLOYMENT_TARGET}")
        endif()
    endif()
elseif(UNIX AND NOT APPLE)
    # Linux-specific conda-forge integration
    if(DEFINED ENV{PREFIX})
        # Set RPATH for conda environment
        set(CMAKE_INSTALL_RPATH "$ENV{PREFIX}/lib")
        set(CMAKE_BUILD_RPATH "$ENV{PREFIX}/lib")
        set(CMAKE_BUILD_WITH_INSTALL_RPATH ON)
        set(CMAKE_INSTALL_RPATH_USE_LINK_PATH ON)
    endif()
endif()

# Debugging output
message(STATUS "Conda-forge toolchain configuration:")
message(STATUS "  CMAKE_PREFIX_PATH: ${CMAKE_PREFIX_PATH}")
message(STATUS "  CMAKE_FIND_ROOT_PATH: ${CMAKE_FIND_ROOT_PATH}")
if(DEFINED ENV{PKG_CONFIG_PATH})
    message(STATUS "  PKG_CONFIG_PATH: $ENV{PKG_CONFIG_PATH}")
else()
    message(STATUS "  PKG_CONFIG_PATH: <not set>")
endif()
message(STATUS "  PkgConfig found: ${PkgConfig_FOUND}")
'

        $toolchain_content | save conda_toolchain.cmake
        print "✓ Created conda_toolchain.cmake"
        $toolchain_found = true
    }

    # Validate conda environment
    if ($env.PREFIX | is-empty) {
        print "Warning: PREFIX environment variable not set - some system libraries may not be found"
    } else {
        print $"Using conda prefix: ($env.PREFIX)"
    }

    # Configure with CMake
    print $"Running cmake with args: ($cmake_args | str join ' ')"
    print "CMake configuration may show warnings about missing libraries - this is normal if they're not installed"
    ^cmake ...$cmake_args



    if $env.LAST_EXIT_CODE != 0 {
        print "CMake configuration failed. Common issues:"
        print "  - Missing system dependencies in conda environment"
        print "  - Incorrect library paths"
        print "  - CMake version compatibility"
        error make {msg: "CMake configuration failed"}
    }

    print "✓ CMake configuration successful"

    # Build
    print "Building with Ninja..."
    cd build

    # Verify build directory exists and has required files
    if not ("build.ninja" | path exists) {
        error make {msg: "Ninja build files not generated - CMake configuration may have failed"}
    }

    let cpu_count = ($env.CPU_COUNT? | default "4")
    print $"Building with ($cpu_count) parallel jobs..."
    print "Build may take several minutes depending on system performance..."

    ^cmake --build . -j $cpu_count

    if $env.LAST_EXIT_CODE != 0 {
        print "Build failed. Common issues:"
        print "  - Missing header files for system libraries"
        print "  - Linker errors with system libraries"
        print "  - Compiler compatibility issues"
        print "Check build output above for specific error details"
        error make {msg: "Build failed"}
    }

    print "✓ Build completed successfully"

    # Security: Create directories with proper permissions
    mkdir $"($env.PREFIX)/bin"
    mkdir $"($env.PREFIX)/share"

    # Security: Set secure permissions on directories
    if ($nu.os-info.name != "windows") {
        ^chmod 755 $"($env.PREFIX)/bin"
        ^chmod 755 $"($env.PREFIX)/share"
    }

    # Determine server executable name
    let mumble_server_exec = match ($nu.os-info.name) {
        "macos" => "mumble-server"
        "linux" => "mumble-server"
        "windows" => "mumble-server.exe"
        _ => "mumble-server"
    }

    # Verify binary exists and validate it
    if not ($mumble_server_exec | path exists) {
        print $"Available files in build directory:"
        ls | each { |file| print $"  ($file.name)" }
        error make {msg: $"Mumble server binary not found: ($mumble_server_exec)"}
    }

    # Basic binary validation (check if it's executable)
    if ($nu.os-info.name != "windows") {
        let file_info = (^file $mumble_server_exec | str trim)
        if not ($file_info | str contains "executable") {
            print $"Warning: Binary may not be properly built: ($file_info)"
        } else {
            print $"✓ Binary validation passed: ($file_info)"
        }
    }

    # Install server binary with secure permissions
    let target_binary = $"($env.PREFIX)/bin/($mumble_server_exec)"
    print $"Installing server binary to: ($target_binary)"
    cp $mumble_server_exec $target_binary

    if ($nu.os-info.name != "windows") {
        ^chmod 755 $target_binary  # Secure: not world-writable
    }

    print $"✓ Installed server binary: ($target_binary)"

    # Install service configuration file on Linux
    if ($nu.os-info.name == "linux") {
        print "Installing service configuration file..."

        let config_dir = $"($env.PREFIX)/etc/mumble"
        mkdir $config_dir

        # Security: Set secure permissions on config directory
        ^chmod 755 $config_dir

        # Security: Validate source config file exists
        let src_config = $"($env.SRC_DIR)/service-config/service.yaml"
        if not ($src_config | path exists) {
            error make {msg: $"Source config file not found: ($src_config)"}
        }

        let dest_config = $"($config_dir)/service.yaml"
        cp $src_config $dest_config

        # Security: Set secure permissions on config file
        ^chmod 644 $dest_config  # Read-only for group/others

        # Verify the file was placed correctly
        if ($"($config_dir)/service.yaml" | path exists) {
            print $"✓ Service configuration installed to: ($config_dir)/service.yaml"
        } else {
            error make {msg: $"Failed to install service configuration to: ($config_dir)/service.yaml"}
        }
    }

    # Install license files
    print "Installing license files..."
    let license_dir = $"($env.PREFIX)/share/licenses/mumble-server"
    mkdir $license_dir

    # Security: Set secure permissions on license directory
    if ($nu.os-info.name != "windows") {
        ^chmod 755 $license_dir
    }

    # Copy main license
    let main_license = $"($env.SRC_DIR)/src/mumble/LICENSE"
    if ($main_license | path exists) {
        cp $main_license $"($license_dir)/LICENSE"
        if ($nu.os-info.name != "windows") {
            ^chmod 644 $"($license_dir)/LICENSE"
        }
        print $"✓ Main license installed: ($license_dir)/LICENSE"
    } else {
        print $"Warning: Main license file not found at ($main_license)"
    }

    # Copy 3rd party licenses if they exist
    let third_party_license = $"($env.SRC_DIR)/src/mumble/3rdPartyLicenses"
    if ($third_party_license | path exists) {
        cp -r $third_party_license $license_dir
        if ($nu.os-info.name != "windows") {
            # Set directory permissions using nushell
            let third_party_dir = ($license_dir + "/3rdPartyLicenses")
            ^chmod 755 $third_party_dir
            # Set file permissions recursively using nushell built-in commands
            try {
                cd $third_party_dir
                glob "**/*" | where ($it | path type) == "file" | each { |file| ^chmod 644 $file }
                cd -
            } catch {
                print "Warning: Could not set permissions on 3rd party license files"
            }
        }
        print $"✓ 3rd party licenses installed: ($license_dir)/3rdPartyLicenses"
    }

    # Final validation
    if ($target_binary | path exists) {
        print "✓ Final installation verification passed"
        print "✓ Mumble VoIP server installed successfully"
        print $"  Server binary: ($target_binary)"
        print $"  License files: ($license_dir)/"
        if ($nu.os-info.name == "linux") {
            print $"  Service config: ($env.PREFIX)/etc/mumble/service.yaml"
        }

        # Show linked libraries for debugging (Linux/macOS)
        if ($nu.os-info.name == "linux") {
            try {
                let ldd_output = (^ldd $target_binary | head -5 | str join "\n")
                print $"  Linked libraries (first 5):\n($ldd_output)"
            } catch {
                print "  Could not check linked libraries"
            }
        } else if ($nu.os-info.name == "macos") {
            try {
                let otool_output = (^otool -L $target_binary | head -5 | str join "\n")
                print $"  Linked libraries (first 5):\n($otool_output)"
            } catch {
                print "  Could not check linked libraries"
            }
        }
    } else {
        error make {msg: "Installation verification failed - binary not found at target location"}
    }
}
