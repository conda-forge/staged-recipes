#!/usr/bin/env nu

def main [] {
    mkdir build
    cd build

    let cmake_args = if ($nu.os-info.name == "windows") {
        [
            "-GNinja"
            "-DCMAKE_BUILD_TYPE=Release"
            "-DGSL_TEST=OFF"
            "-DGSL_INSTALL=ON"
            $"-DCMAKE_INSTALL_PREFIX=($env.PREFIX | path join 'Library')"
            $"-DCMAKE_INSTALL_INCLUDEDIR=($env.PREFIX | path join 'Library' 'include')"
            $"-DCMAKE_INSTALL_DATADIR=($env.PREFIX | path join 'Library' 'share')"
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
