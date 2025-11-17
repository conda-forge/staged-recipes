#!/usr/bin/env nu

def main [] {
    mkdir build
    cd build

    let install_prefix = if ($nu.os-info.name == "windows") {
        ($env.PREFIX | str replace --all '\\' '/') + "/Library"
    } else {
        $env.PREFIX
    }

    let cmake_args = [
        "-GNinja"
        "-DCMAKE_BUILD_TYPE=Release"
        "-DBUILD_SHARED_LIBS=ON"
        $"-DCMAKE_INSTALL_PREFIX=($install_prefix)"
    ]

    ^cmake ...$cmake_args $env.SRC_DIR
    ^ninja
    ^ninja install

}
