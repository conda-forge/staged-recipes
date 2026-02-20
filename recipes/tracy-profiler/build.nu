#!/usr/bin/env nu

# Tracy Profiler nushell build script
# Combines Unix and Windows build logic

def main [] {
    print "Building Tracy Profiler client library..."

    # Create build directory
    mkdir build
    cd build

    # Prepare CMake arguments
    mut cmake_args = [
        "-GNinja"
        "-DCMAKE_BUILD_TYPE=Release"
        "-DTRACY_ENABLE=ON"
        "-DTRACY_ON_DEMAND=ON"
        "-DTRACY_NO_CALLSTACK=OFF"
        "-DTRACY_NO_CALLSTACK_INLINES=OFF"
        "-DTRACY_NO_FRAME_IMAGE=OFF"
        "-DTRACY_NO_VSYNC_CAPTURE=OFF"
    ]

    # Add platform-specific CMake arguments
    match $nu.os-info.name {
        "windows" => {
            $cmake_args = ($cmake_args | append [
                $"-DCMAKE_PREFIX_PATH=($env.PREFIX)"
                $"-DCMAKE_INSTALL_PREFIX=($env.PREFIX)"
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

    let header_path = match $nu.os-info.name {
        "windows" => $"($env.PREFIX)/Library/include/tracy/tracy/Tracy.hpp"
        _ => $"($env.PREFIX)/include/tracy/tracy/Tracy.hpp"
    }

    let cmake_config_path = match $nu.os-info.name {
        "windows" => $"($env.PREFIX)/Library/lib/cmake/Tracy/TracyConfig.cmake"
        _ => $"($env.PREFIX)/lib/cmake/Tracy/TracyConfig.cmake"
    }

    if not ($header_path | path exists) {
        error make {msg: $"ERROR: Tracy.hpp header not found at ($header_path)"}
    }

    if not ($cmake_config_path | path exists) {
        error make {msg: $"ERROR: Tracy CMake config not found at ($cmake_config_path)"}
    }

    print "✓ Tracy profiler client library installed successfully"
    print $"  Headers: ($header_path)"
    print $"  CMake config: ($cmake_config_path)"
}
