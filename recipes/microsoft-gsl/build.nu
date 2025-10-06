#!/usr/bin/env nu

def main [] {
    mkdir build
    cd build

    let cmake_args = if ($nu.os-info.name == "windows") {
        # Use forward slashes consistently on Windows to avoid escape sequence issues
        let prefix_path = ($env.PREFIX | str replace --all '\\' '/')
        [
            "-GNinja"
            "-DCMAKE_BUILD_TYPE=Release"
            "-DGSL_TEST=OFF"
            "-DGSL_INSTALL=ON"
            $"-DCMAKE_INSTALL_PREFIX=($prefix_path)/Library"
            $"-DCMAKE_INSTALL_INCLUDEDIR=($prefix_path)/Library/include"
            $"-DCMAKE_INSTALL_DATADIR=($prefix_path)/Library/share"
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
