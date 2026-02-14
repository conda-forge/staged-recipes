#! /bin/bash
set -e

cmake -B build \
  -S ${SRC_DIR} \
  ${CMAKE_ARGS} \
  -GNinja \
  -DWERROR=OFF \
  -DCMAKE_POLICY_VERSION_MINIMUM=3.5

cmake --build build -j ${CPU_COUNT}

# Run tests with a 60 second timeout per test, excluding problematic binary output tests
ctest --test-dir build --timeout 60 -E "examples_convert_xml_pbf" --output-on-failure

cmake --install build
