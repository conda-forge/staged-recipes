#!/usr/bin/env bash
set -euxo pipefail

shared_linker_flags="${LDFLAGS}"
if [[ "${target_platform}" == osx-* ]]; then
  # With unique-vtable assumptions, thrift1 fails with std::bad_cast while
  # generating code: https://github.com/facebook/fbthrift/issues/618
  export CXXFLAGS="${CXXFLAGS} -fno-assume-unique-vtables"
  # The thrift libraries reference each other's symbols in cycles (for
  # example thriftprotocol uses code compiled into thriftmetadata), which
  # ld64 rejects for dylibs. Leave those symbols for dyld to resolve.
  shared_linker_flags="${shared_linker_flags} -Wl,-undefined,dynamic_lookup"
fi

cmake -S . -B build -G Ninja ${CMAKE_ARGS} \
  -DCMAKE_SHARED_LINKER_FLAGS="${shared_linker_flags}" \
  -DCMAKE_CXX_STANDARD=20 \
  -DBUILD_SHARED_LIBS=ON \
  -DTHRIFT_BENCHMARKS=OFF \
  -Dthriftpy=OFF \
  -Dthriftpy3=OFF \
  -Dthrift_python=OFF \
  -Denable_tests=OFF
cmake --build build --parallel "${CPU_COUNT}"
cmake --install build
