#!/usr/bin/env nu

# Microsoft GSL nushell build script
# Combines Unix and Windows build logic

def main [] {
    print "Building Microsoft Guidelines Support Library..."

    # Create build directory
    mkdir build
    cd build

    # Prepare CMake arguments
    mut cmake_args = [
        "-GNinja"
        "-DCMAKE_BUILD_TYPE=Release"
        "-DGSL_TEST=OFF"
        "-DGSL_INSTALL=ON"
    ]

    # Add platform-specific CMake arguments
    match $nu.os-info.name {
        "windows" => {
            $cmake_args = ($cmake_args | append [
                $"-DCMAKE_PREFIX_PATH=($env.LIBRARY_PREFIX)"
                $"-DCMAKE_INSTALL_PREFIX=($env.LIBRARY_PREFIX)"
                $"-DCMAKE_INSTALL_INCLUDEDIR=($env.LIBRARY_INC)"
            ])

            # Set up Windows environment
            if ($env.CMAKE_ARGS? != null) {
                let win_args = ($env.CMAKE_ARGS | split row " ")
                $cmake_args = ($cmake_args | append $win_args)
            }
        }
        _ => {
            # Unix systems (Linux, macOS)
            $cmake_args = ($cmake_args | append [
                $"-DCMAKE_INSTALL_PREFIX=($env.PREFIX)"
            ])

            # Add CMAKE_ARGS if available
            if ($env.CMAKE_ARGS? != null) {
                let unix_args = ($env.CMAKE_ARGS | split row " ")
                $cmake_args = ($cmake_args | append $unix_args)
            }
        }
    }

    # Configure with CMake
    print $"Running cmake with args: ($cmake_args | str join ' ')"
    ^cmake ...$cmake_args ..

    if $env.LAST_EXIT_CODE != 0 {
        error make {msg: "CMake configuration failed"}
    }

    # Build
    print "Building with Ninja..."
    ^ninja

    if $env.LAST_EXIT_CODE != 0 {
        error make {msg: "Build failed"}
    }

    # Install
    print "Installing..."
    ^ninja install

    if $env.LAST_EXIT_CODE != 0 {
        error make {msg: "Installation failed"}
    }

    # Verify installation
    print "Verifying installation..."
    print $"PREFIX environment variable: ($env.PREFIX)"
    if $nu.os-info.name == "windows" {
        print $"LIBRARY_PREFIX environment variable: ($env.LIBRARY_PREFIX)"
        print $"LIBRARY_INC environment variable: ($env.LIBRARY_INC)"
    }
    print $"OS: ($nu.os-info.name)"

    let header_path = match $nu.os-info.name {
        "windows" => $"($env.LIBRARY_INC)/gsl/gsl"
        _ => $"($env.PREFIX)/include/gsl/gsl"
    }

    let cmake_config_path = match $nu.os-info.name {
        "windows" => $"($env.LIBRARY_PREFIX)/share/cmake/Microsoft.GSL/Microsoft.GSLConfig.cmake"
        _ => $"($env.PREFIX)/share/cmake/Microsoft.GSL/Microsoft.GSLConfig.cmake"
    }

    print $"Looking for header at: ($header_path)"
    print $"Looking for CMake config at: ($cmake_config_path)"

    # List what's actually in the include directory
    let include_dir = match $nu.os-info.name {
        "windows" => $env.LIBRARY_INC
        _ => $"($env.PREFIX)/include"
    }

    if ($include_dir | path exists) {
        print $"Contents of ($include_dir):"
        ls $include_dir | each {|item| print $"  ($item.name)"}

        let gsl_dir = $"($include_dir)/gsl"
        if ($gsl_dir | path exists) {
            print $"Contents of ($gsl_dir):"
            ls $gsl_dir | each {|item| print $"  ($item.name)"}
        }
    } else {
        print $"Include directory does not exist: ($include_dir)"
    }

    if not ($header_path | path exists) {
        error make {msg: $"ERROR: GSL main header not found at ($header_path)"}
    }

    if not ($cmake_config_path | path exists) {
        error make {msg: $"ERROR: GSL CMake config not found at ($cmake_config_path)"}
    }

    print "✓ Microsoft GSL installed successfully"
    print $"  Headers: ($header_path)"
    print $"  CMake config: ($cmake_config_path)"
}
