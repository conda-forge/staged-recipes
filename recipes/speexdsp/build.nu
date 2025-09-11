#!/usr/bin/env nu

def main [] {
    cp ($env.RECIPE_DIR | path join "CMakeLists.txt") "./CMakeLists.txt"
    cp -r ($env.RECIPE_DIR | path join "cmake") "./cmake"

    mkdir build
    cd build

    mut cmake_args = [
        "-DCMAKE_BUILD_TYPE=Release"
        "-DBUILD_SHARED_LIBS=ON"
        "-DENABLE_SSE=ON"
        "-DENABLE_FIXED_POINT=OFF"
        "-DENABLE_FLOAT_API=ON"
        "-DBUILD_EXAMPLES=OFF"
        "-GNinja"
    ]

    if ($nu.os-info.name == "windows") {
        let install_prefix = $env.PREFIX | path join "Library"
        $cmake_args = ($cmake_args | append [
            $"-DCMAKE_INSTALL_PREFIX=($install_prefix)"
            $"-DCMAKE_INSTALL_LIBDIR=($install_prefix)\\lib"
            $"-DCMAKE_INSTALL_INCLUDEDIR=($install_prefix)\\include"
            $"-DCMAKE_INSTALL_BINDIR=($install_prefix)\\bin"
        ])
    } else {
        $cmake_args = ($cmake_args | append [
            $"-DCMAKE_INSTALL_PREFIX=($env.PREFIX)"
        ])
    }

    ^cmake ...$cmake_args $env.SRC_DIR
    ^cmake --build . --config Release
    ^cmake --install . --config Release
}
