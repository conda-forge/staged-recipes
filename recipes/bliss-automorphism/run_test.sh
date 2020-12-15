#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

# Test that Bliss library can be properly included (no broken dependecies, missing files...),
# including via the installed CMake targets

cat > bliss-test.cpp << 'EOF'
#include <bliss/graph.hh>

int main() {
	bliss::Graph graph{2};
	graph.add_edge(0, 1);
}
EOF

cat > CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.0)

find_package(Bliss REQUIRED)
add_executable(bliss-test bliss-test.cpp)
target_link_libraries(bliss-test PUBLIC Bliss::libbliss)
EOF

cmake -B build
cmake --build build --parallel ${CPU_COUNT}
./build/bliss-test
