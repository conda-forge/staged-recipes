#!/usr/bin/env bash
set -euxo pipefail

if [[ "${target_platform}" == osx-* ]]; then
  # With unique-vtable assumptions, thrift1 fails with std::bad_cast while
  # generating code: https://github.com/facebook/fbthrift/issues/618
  export CXXFLAGS="${CXXFLAGS} -fno-assume-unique-vtables"
fi

cmake -S . -B build -G Ninja ${CMAKE_ARGS} \
  -DCMAKE_CXX_STANDARD=20 \
  -DBUILD_SHARED_LIBS=ON \
  -DTHRIFT_BENCHMARKS=OFF \
  -Dthriftpy=OFF \
  -Dthriftpy3=OFF \
  -Dthrift_python=OFF \
  -Denable_tests=OFF
cmake --build build --parallel "${CPU_COUNT}"
cmake --install build
