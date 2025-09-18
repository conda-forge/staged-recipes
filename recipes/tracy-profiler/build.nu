#!/usr/bin/env nu

def main [] {
    mkdir build
    cd build

    let install_prefix = if $nu.os-info.name == "windows" {
        $env.PREFIX | path join "Library"
    } else {
        $env.PREFIX
    }

    let cmake_args = [
        "-GNinja"
        "-DCMAKE_BUILD_TYPE=Release"
        "-DTRACY_ENABLE=ON"
        "-DTRACY_ON_DEMAND=ON"
        "-DTRACY_NO_CALLSTACK=OFF"
        "-DTRACY_NO_CALLSTACK_INLINES=OFF"
        "-DTRACY_NO_FRAME_IMAGE=OFF"
        "-DTRACY_NO_VSYNC_CAPTURE=OFF"
        $"-DCMAKE_INSTALL_PREFIX=($install_prefix)"
    ]

    ^cmake ...$cmake_args ..
    ^ninja
    ^ninja install
}
