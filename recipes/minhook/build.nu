#!/usr/bin/env nu

def main [] {
    mkdir build
    cd build

    let install_prefix = if ($nu.os-info.name == "windows") {
        $env.PREFIX | path join "Library"
    } else {
        $env.PREFIX
    }

    let cmake_args = [
        "-GNinja"
        "-DCMAKE_BUILD_TYPE=Release"
        "-DBUILD_SHARED_LIBS=OFF"
        $"-DCMAKE_INSTALL_PREFIX=($install_prefix)"
    ]

    ^cmake ...$cmake_args $env.SRC_DIR
    ^ninja
    ^ninja install

    if ($nu.os-info.name == "windows") {
        let lib_dir = ($env.PREFIX | path join "Library" "lib")
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
