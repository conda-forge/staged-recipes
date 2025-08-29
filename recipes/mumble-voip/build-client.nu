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
        # Force CMake to use conda-forge packages instead of bundled versions
        $"-Dnlohmann_json_DIR=($env.PREFIX)/lib/cmake/nlohmann_json"
        $"-Dspdlog_DIR=($env.PREFIX)/lib/cmake/spdlog"
        $"-Dutfcpp_DIR=($env.PREFIX)/share/utf8cpp/cmake"
        # Force use of system packages instead of bundled ones
        "-Dbundled-json=OFF"
        "-Dbundled-spdlog=OFF"
        "-Dbundled-utf8cpp=OFF"
    ]

    # Add platform-specific arguments
    match ($nu.os-info.name) {
        "linux" => {
            # Set up environment for X11 detection
            $env.PKG_CONFIG_PATH = $"($env.PREFIX)/lib/pkgconfig"
            $env.CMAKE_PREFIX_PATH = $"($env.PREFIX)"
            $env.CPPFLAGS = $"-I($env.PREFIX)/include"

            $cmake_args = ($cmake_args | append [
                "-DCMAKE_CXX_FLAGS=-Wno-error=cpp -Wno-cpp -Wno-deprecated-declarations"
                "-DCMAKE_C_FLAGS=-Wno-error=cpp -Wno-cpp -std=c11"
                $"-DX11_INCLUDE_DIR=($env.PREFIX)/include"
                $"-DX11_LIBRARIES=($env.PREFIX)/lib/libX11($env.SHLIB_EXT);($env.PREFIX)/lib/libXext($env.SHLIB_EXT);($env.PREFIX)/lib/libXi($env.SHLIB_EXT)"
            ])
        }
        "macos" => {
            # Use conda-forge recommended approach for C++ availability
            # MACOSX_SDK_VERSION is set in variants.yaml, let conda handle deployment target
            $cmake_args = ($cmake_args | append [
                "-DCMAKE_CXX_FLAGS=-Wno-deprecated-declarations -D_LIBCPP_DISABLE_AVAILABILITY"
                "-DCMAKE_C_FLAGS=-Wno-deprecated-declarations -std=c11"
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
            ])
        }
    }

    # Configure with CMake
    print $"Running cmake with args: ($cmake_args | str join ' ')"
    ^cmake ...$cmake_args

    if $env.LAST_EXIT_CODE != 0 {
        error make {msg: "CMake configuration failed"}
    }

    # Build
    print "Building with Ninja..."
    cd build
    let cpu_count = ($env.CPU_COUNT? | default "4")
    print $"Building with ($cpu_count) parallel jobs..."
    ^cmake --build . -j $cpu_count

    if $env.LAST_EXIT_CODE != 0 {
        error make {msg: "Build failed"}
    }

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

    # Verify binary exists
    if not ($mumble_exec | path exists) {
        error make {msg: $"Mumble client binary not found: ($mumble_exec)"}
    }

    # Install client binary with secure permissions
    let target_binary = $"($env.PREFIX)/bin/($mumble_exec)"
    cp $mumble_exec $target_binary
    if ($nu.os-info.name != "windows") {
        ^chmod 755 $target_binary
    }



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

    print "✓ Mumble VoIP client built and installed successfully"
}
