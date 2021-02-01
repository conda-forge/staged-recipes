#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.0)

find_package(SOPLEX REQUIRED)
add_executable(example scipoptsuite/soplex/src/example.cpp)
target_link_libraries(example PUBLIC libsoplex)
EOF

cmake -B build
cmake --build build --parallel ${CPU_COUNT}
./build/example

soplex --version
