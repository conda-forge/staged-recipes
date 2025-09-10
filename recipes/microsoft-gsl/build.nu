#!/usr/bin/env nu

# Microsoft GSL simplified build script for rattler-build

def main [] {
    # Create build directory
    mkdir build
    cd build

    # Configure with CMake - handle Windows conda paths properly
    let cmake_args = if ($nu.os-info.name == "windows") {
        [
            "-GNinja"
            "-DCMAKE_BUILD_TYPE=Release"
            "-DGSL_TEST=OFF"
            "-DGSL_INSTALL=ON"
            $"-DCMAKE_INSTALL_PREFIX=($env.PREFIX)\\Library"
            $"-DCMAKE_INSTALL_INCLUDEDIR=($env.PREFIX)\\Library\\include"
            $"-DCMAKE_INSTALL_DATADIR=($env.PREFIX)\\Library\\share"
        ]
    } else {
        [
            "-GNinja"
            "-DCMAKE_BUILD_TYPE=Release"
            "-DGSL_TEST=OFF"
            "-DGSL_INSTALL=ON"
            $"-DCMAKE_INSTALL_PREFIX=($env.PREFIX)"
        ]
    }

    ^cmake ...$cmake_args ..

    # Build and install
    ^ninja
    ^ninja install
}
