#!/usr/bin/env nu

cp ($env.RECIPE_DIR | path join "CMakeLists.txt") "./CMakeLists.txt"

mkdir build
cd build

let install_prefix = if $nu.os-info.name == "windows" {
    ($env.PREFIX | str replace --all '\\' '/') + "/Library"
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

let cmake_args = if $nu.os-info.name == "windows" {
    $cmake_args | append "-GNinja"
} else {
    $cmake_args
}

^cmake ...$cmake_args
^cmake --build . --config Release
^cmake --install . --config Release
