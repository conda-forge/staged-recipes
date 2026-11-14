#!/bin/bash
set -euxo pipefail
test_static=OFF
if [[ "${1:-}" == "--static" ]]; then
    test_static=ON
else
    # The development package must work without the static companion package.
    test ! -e "${PREFIX}/lib/libnccl_m2n.a"
fi
mkdir consumer
cd consumer
cat > CMakeLists.txt <<'EOF'
cmake_minimum_required(VERSION 3.20)
project(consumer LANGUAGES CXX)
find_package(NCCLM2N CONFIG REQUIRED)
add_executable(consumer main.cc)
target_link_libraries(consumer PRIVATE NCCL::m2n)
option(TEST_STATIC "Test the optional static target" OFF)
if(TEST_STATIC)
    add_executable(consumer_static main.cc)
    target_link_libraries(consumer_static PRIVATE NCCL::m2n_static)
elseif(TARGET NCCL::m2n_static)
    message(FATAL_ERROR "Static target is available without the static package")
endif()
EOF
cat > main.cc <<'EOF'
#include <nccl_m2n.h>
int main() { return ncclM2nGetLastError() == nullptr; }
EOF
cmake -S . -B build -G Ninja ${CMAKE_ARGS:-} -DCMAKE_PREFIX_PATH="${PREFIX}" -DTEST_STATIC="${test_static}"
cmake --build build
