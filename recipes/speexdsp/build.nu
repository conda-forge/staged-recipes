#!/usr/bin/env nu

def main [] {
    match $nu.os-info.name {
        "windows" => {
            build_windows_cmake
        }
        _ => {
            build_unix_autotools
        }
    }
}

def build_unix_autotools [] {
    ^sh -c "./autogen.sh"

    let configure_args = [
        $"--prefix=($env.PREFIX)"
        "--disable-static"
        "--enable-shared"
        "--disable-examples"
        "--enable-sse"
        "--enable-fixed-point"
    ]

    ^./configure ...$configure_args
    ^make $"-j($env.CPU_COUNT? | default "4")"
    ^make install
}

def build_windows_cmake [] {
    cp ($env.RECIPE_DIR | path join "CMakeLists.txt") "./CMakeLists.txt"
    cp -r ($env.RECIPE_DIR | path join "cmake") "./cmake"

    mkdir build
    cd build

    let cmake_args = [
        "-DCMAKE_BUILD_TYPE=Release"
        "-DBUILD_SHARED_LIBS=ON"
        "-DENABLE_SSE=ON"
        "-DENABLE_FIXED_POINT=OFF"
        "-DENABLE_FLOAT_API=ON"
        "-DBUILD_EXAMPLES=OFF"
        "-GNinja"
        $"-DCMAKE_INSTALL_PREFIX=($env.PREFIX)\\Library"
        $"-DCMAKE_INSTALL_LIBDIR=($env.PREFIX)\\Library\\lib"
        $"-DCMAKE_INSTALL_INCLUDEDIR=($env.PREFIX)\\Library\\include"
        $"-DCMAKE_INSTALL_BINDIR=($env.PREFIX)\\Library\\bin"
        $env.SRC_DIR
    ]

    ^cmake ...$cmake_args
    ^cmake --build . --config Release
    ^cmake --install . --config Release
}
