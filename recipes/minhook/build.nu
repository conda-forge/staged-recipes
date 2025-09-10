#!/usr/bin/env nu

# MinHook simplified build script for rattler-build

def main [] {
    # Create build directory
    mkdir build
    cd build

    # Configure with CMake - handle Windows conda paths properly
    let cmake_args = if ($nu.os-info.name == "windows") {
        [
            "-GNinja"
            "-DCMAKE_BUILD_TYPE=Release"
            "-DBUILD_SHARED_LIBS=OFF"
            $"-DCMAKE_INSTALL_PREFIX=($env.PREFIX)\\Library"
        ]
    } else {
        [
            "-GNinja"
            "-DCMAKE_BUILD_TYPE=Release"
            "-DBUILD_SHARED_LIBS=OFF"
            $"-DCMAKE_INSTALL_PREFIX=($env.PREFIX)"
        ]
    }

    ^cmake ...$cmake_args $env.SRC_DIR

    # Build and install
    ^ninja
    ^ninja install

    # Handle architecture-specific library naming for Windows
    if ($nu.os-info.name == "windows") {
        let lib_dir = ($env.PREFIX | path join "Library" "lib")

        # Copy architecture-specific library to standard name if needed
        let x64_lib = ($lib_dir | path join "minhook.x64.lib")
        let x32_lib = ($lib_dir | path join "minhook.x32.lib")
        let standard_lib = ($lib_dir | path join "minhook.lib")

        if ($x64_lib | path exists) and not ($standard_lib | path exists) {
            cp $x64_lib $standard_lib
        } else if ($x32_lib | path exists) and not ($standard_lib | path exists) {
            cp $x32_lib $standard_lib
        }
    }
}
