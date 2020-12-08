#!/usr/bin/env bash
set -ex

cd ${SRC_DIR}

mkdir -p build-${c_compiler}
cd build-${c_compiler}

# Configure.
cmake -G "Unix Makefiles"           \
      -DCMAKE_BUILD_TYPE=Release    \
      ${SRC_DIR}

# Build.
cmake --build .

# Install the bits manually
mkdir -p ${PREFIX}/lib ${PREFIX}/include
cp libittnotify.a ${PREFIX}/lib
cp ${SRC_DIR}/include/ittnotify.h           \
        ${SRC_DIR}/include/jitprofiling.h   \
        ${SRC_DIR}/include/libittnotify.h   \
        ${PREFIX}/include
