#!/usr/bin/env bash

set -ex

# vcpkg install zlib sdl2

mkdir build && cd build
cmake ../ -DCMAKE_BUILD_TYPE=Release
cmake --build . --target install

# find_package(ale REQUIRED)
# target_link_libraries(YourTarget ale::ale-lib)