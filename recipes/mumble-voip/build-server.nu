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
        # "-Dcelt=OFF"
        "-Dice=OFF"
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
        # Force CMake to use conda-forge packages instead of bundled versions
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
                # $"-DX11_INCLUDE_DIR=($env.PREFIX)/include"
                # $"-DX11_LIBRARIES=($env.PREFIX)/lib/libX11($env.SHLIB_EXT);($env.PREFIX)/lib/libXext($env.SHLIB_EXT);($env.PREFIX)/lib/libXi($env.SHLIB_EXT)"
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
    cd build
    let cpu_count = ($env.CPU_COUNT? | default "4")
    print $"Building with ($cpu_count) parallel jobs..."
    ^cmake --build . -j $cpu_count

    if $env.LAST_EXIT_CODE != 0 {
        error make {msg: "Build failed"}
    }

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

    # Security: Validate binary exists before installation
    if not ($mumble_server_exec | path exists) {
        error make {msg: $"Mumble server binary not found: ($mumble_server_exec)"}
    }

    # Install server binary with secure permissions
    let target_binary = $"($env.PREFIX)/bin/($mumble_server_exec)"
    print $"Installing server binary to: ($target_binary)"
    cp $mumble_server_exec $target_binary

    if ($nu.os-info.name != "windows") {
        ^chmod 755 $target_binary  # Secure: not world-writable
    }

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

    print "✓ Mumble VoIP server installed successfully"
    print $"  Server binary: ($target_binary)"
    print $"  License files: ($license_dir)/"
    if ($nu.os-info.name == "linux") {
        print $"  Service config: ($env.PREFIX)/etc/mumble/service.yaml"
    }
}
