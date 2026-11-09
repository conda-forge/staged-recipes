#!/bin/bash
set -euxo pipefail
mkdir consumer
cd consumer
cat > CMakeLists.txt <<'EOF'
cmake_minimum_required(VERSION 3.20)
project(consumer LANGUAGES CXX)
find_package(NCCLM2N CONFIG REQUIRED)
add_executable(consumer main.cc)
target_link_libraries(consumer PRIVATE NCCL::m2n)
add_executable(consumer_static main.cc)
target_link_libraries(consumer_static PRIVATE NCCL::m2n_static)
EOF
cat > main.cc <<'EOF'
#include <nccl_m2n.h>
int main() { return 0; }
EOF
cmake -S . -B build -G Ninja -DCMAKE_PREFIX_PATH="${PREFIX}"
cmake --build build
