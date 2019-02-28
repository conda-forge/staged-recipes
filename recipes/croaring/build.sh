#!/bin/bash

export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

mv ./benchmarks/CMakeLists.txt ./benchmarks/CMakeLists.old
awk '/add_c_benchmark\(create_benchmark\)/ { \
    print "# fixe source: https://github.com/dotnet/coreclr/pull/15093/files"; \
    print "if(CLR_CMAKE_PLATFORM_DARWIN)"; \
    print "  # Enable non-POSIX pthreads APIs, which by default are not included in the pthreads header"; \
    print "  add_definitions(-D_DARWIN_C_SOURCE)"; \
    print "endif(CLR_CMAKE_PLATFORM_DARWIN)"; \
    print; next }1' \
    ./benchmarks/CMakeLists.old > ./benchmarks/CMakeLists.txt
rm ./benchmarks/CMakeLists.old

mkdir -p build
cd build
cmake \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_INSTALL_LIBDIR=${PREFIX}/lib \
    ${SRC_DIR}

make install
make test