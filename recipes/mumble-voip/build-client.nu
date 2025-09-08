#!/usr/bin/env nu

# Mumble VoIP Client nushell build script
# Builds the mumble-client package with conda-forge dependencies

def main [] {
    print "Building Mumble VoIP client..."

    # Navigate to mumble source directory
    cd src/mumble

    # Build client
    mut cmake_args = [
        "-B" "build"
        "-G" "Ninja"
        "-DCMAKE_BUILD_TYPE=Release"
        "-DCMAKE_CXX_STANDARD=20"
        "-DCMAKE_CXX_STANDARD_REQUIRED=ON"
        "-Dspeechd=OFF"
        "-Doverlay=OFF"
        "-Doverlay-xcompile=OFF"
        "-Dzeroconf=OFF"
        "-Dcelt=OFF"
        "-Dice=OFF"
        "-Dclient=ON"
        "-Dserver=OFF"
        $"-DCMAKE_PREFIX_PATH=($env.PREFIX)"
        $"-DBOOST_ROOT=($env.PREFIX)"
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
        "-Dbundled-gsl=OFF"
        "-DTRACY_ENABLE=OFF"
    ]

    # Add platform-specific arguments
    match ($nu.os-info.name) {
        "linux" => {
            # Set up environment for X11 detection
            $env.PKG_CONFIG_PATH = $"($env.PREFIX)/lib/pkgconfig:($env.PKG_CONFIG_PATH | default '')"
            $env.CMAKE_PREFIX_PATH = $"($env.PREFIX):($env.CMAKE_PREFIX_PATH | default '')"
            $env.CPPFLAGS = $"-I($env.PREFIX)/include ($env.CPPFLAGS | default '')"
            $env.LDFLAGS = $"-L($env.PREFIX)/lib ($env.LDFLAGS | default '')"

            $cmake_args = ($cmake_args | append [
                "-DCMAKE_CXX_FLAGS=-Wno-error=cpp -Wno-cpp -Wno-deprecated-declarations"
                "-DCMAKE_C_FLAGS=-Wno-error=cpp -Wno-cpp -std=c11"
                $"-DX11_INCLUDE_DIR=($env.PREFIX)/include"
                $"-DX11_LIBRARIES=($env.PREFIX)/lib/libX11($env.SHLIB_EXT);($env.PREFIX)/lib/libXext($env.SHLIB_EXT);($env.PREFIX)/lib/libXi($env.SHLIB_EXT)"
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
        print "⚠ CMake configuration files not found, creating minimal versions..."

        # Create minimal cmake_system_libs.cmake
        let cmake_content = '# Minimal system library configuration
message(STATUS "Using system libraries where available via conda-forge")
add_compile_definitions(USE_SYSTEM_JSON)
add_compile_definitions(USE_SYSTEM_SPDLOG)
add_compile_definitions(USE_SYSTEM_UTF8CPP)
'

        $cmake_content | save cmake_system_libs.cmake
        print "✓ Created minimal cmake_system_libs.cmake"
        $cmake_found = true
    }

    if not $toolchain_found {
        # Create minimal conda_toolchain.cmake
        let toolchain_content = '# Minimal conda-forge toolchain
if(DEFINED ENV{PREFIX})
    set(CMAKE_PREFIX_PATH "$ENV{PREFIX}" ${CMAKE_PREFIX_PATH})
    list(APPEND CMAKE_PREFIX_PATH "$ENV{PREFIX}/lib/cmake")
    if(WIN32)
        list(APPEND CMAKE_PREFIX_PATH "$ENV{PREFIX}/Library")
    endif()
    message(STATUS "Conda environment: $ENV{PREFIX}")
endif()
'

        $toolchain_content | save conda_toolchain.cmake
        print "✓ Created minimal conda_toolchain.cmake"
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
    print "Creating installation directories..."
    mkdir $"($env.PREFIX)/bin"
    mkdir $"($env.PREFIX)/share"

    # Security: Set secure permissions on directories
    if ($nu.os-info.name != "windows") {
        ^chmod 755 $"($env.PREFIX)/bin"
        ^chmod 755 $"($env.PREFIX)/share"
    }

    # Install client binary
    print "Installing client binary..."
    let mumble_exec = match ($nu.os-info.name) {
        "macos" => "mumble"
        "linux" => "mumble"
        "windows" => "mumble.exe"
        _ => "mumble"
    }

    # Verify binary exists and validate it
    if not ($mumble_exec | path exists) {
        print $"Available files in build directory:"
        ls | each { |file| print $"  ($file.name)" }
        error make {msg: $"Mumble client binary not found: ($mumble_exec)"}
    }

    # Basic binary validation (check if it's executable)
    if ($nu.os-info.name != "windows") {
        let file_info = (^file $mumble_exec | str trim)
        if not ($file_info | str contains "executable") {
            print $"Warning: Binary may not be properly built: ($file_info)"
        } else {
            print $"✓ Binary validation passed: ($file_info)"
        }
    }

    # Install client binary with secure permissions
    let target_binary = $"($env.PREFIX)/bin/($mumble_exec)"
    cp $mumble_exec $target_binary
    if ($nu.os-info.name != "windows") {
        ^chmod 755 $target_binary
    }

    print $"✓ Installed binary: ($target_binary)"



    # Install license files
    print "Installing license files..."
    let license_dir = $"($env.PREFIX)/share/licenses/mumble-client"
    mkdir $license_dir

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
        print $"✓ Mumble VoIP client built and installed successfully"
        print $"  Binary: ($target_binary)"
        print $"  Licenses: ($license_dir)"

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
