#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

# Test that the Papilo developement package can be properly included (no broken dependecies, missing
# files...), including via the installed CMake targets

cat > papilo-test.cpp << 'EOF'
#include <papilo/core/Problem.hpp>

int main() {
	papilo::Problem<float> prob;
	prob.setName("test");
}
EOF

cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.0)

find_package(PAPILO REQUIRED)
add_executable(papilo-test papilo-test.cpp)
target_link_libraries(papilo-test PUBLIC ${PAPILO_IMPORTED_TARGETS})
EOF

cmake -B build
cmake --build build --parallel ${CPU_COUNT}
./build/papilo-test
