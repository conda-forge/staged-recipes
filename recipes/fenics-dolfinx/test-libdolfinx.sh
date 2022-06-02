#!/usr/bin/env bash
set -ex
pkg-config --libs dolfinx

# not sure why this custom command isn't run by cmake
ffcx cpp/test/poisson.py -o cpp/test

# disable clang availability check
if [[ "$target_platform" == "osx-64" ]]; then
  export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

cmake -DCMAKE_BUILD_TYPE=Developer -B build-test/ -S cpp/test/
cmake --build build-test --parallel "${CPU_COUNT}"
cd build-test

ctest -V --output-on-failure -R unittests
