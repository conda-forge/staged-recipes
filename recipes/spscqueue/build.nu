#!/usr/bin/env nu

# SPSCQueue simplified build script for rattler-build

# Copy conda-compatible CMakeLists.txt
cp ($env.RECIPE_DIR | path join "CMakeLists.txt") "./CMakeLists.txt"

mkdir build
cd build

# Configure and build with CMake - use proper Windows install prefix
let install_prefix = if $nu.os-info.name == "windows" {
    $env.PREFIX | path join "Library"
} else {
    $env.PREFIX
}

let cmake_args = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DCMAKE_CXX_STANDARD=11"
    "-DCMAKE_CXX_STANDARD_REQUIRED=ON"
    "-DBUILD_TESTING=OFF"
    $"-DCMAKE_INSTALL_PREFIX=($install_prefix)"
    $env.SRC_DIR
]

if $nu.os-info.name == "windows" {
    let cmake_args = ($cmake_args | append "-GNinja")
}

^cmake ...$cmake_args
^cmake --build . --config Release
^cmake --install . --config Release
