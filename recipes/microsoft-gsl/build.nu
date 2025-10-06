#!/usr/bin/env nu

def main [] {
    mkdir build
    cd build

    let cmake_args = if ($nu.os-info.name == "windows") {
        # Use forward slashes for prefix and relative paths for install directories
        let prefix_path = ($env.PREFIX | str replace --all '\\' '/')
        [
            "-GNinja"
            "-DCMAKE_BUILD_TYPE=Release"
            "-DGSL_TEST=OFF"
            "-DGSL_INSTALL=ON"
            $"-DCMAKE_INSTALL_PREFIX=($prefix_path)/Library"
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
    ^ninja
    ^ninja install
}
