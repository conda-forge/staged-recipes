#!/bin/bash

# CMake extra configuration:
extra_cmake_args=(
    -G Ninja
    -D BUILD_SHARED_LIBS=ON
    # SSL/RTL X509 authentication
    -D SSLAUTHENTICATION=ON
    # Build client
    -D CLIENT_ONLY=ON
    -D SERVER_ONLY=OFF
    # Enable Cap’n Proto serialisation
    -D ENABLE_CAPNP=ON
    # Enable LibMemcached
    -D NO_MEMCACHE=OFF
    # Wrappers
    -D NO_WRAPPERS=OFF
    -D NO_CXX_WRAPPER=OFF
    -D NO_IDL_WRAPPER=ON
    -D NO_PYTHON_WRAPPER=OFF
    -D NO_JAVA_WRAPPER=OFF
    -D FAT_IDL=OFF
    # CLI
    -D NO_CLI=OFF
)

cmake ${CMAKE_ARGS} "${extra_cmake_args[@]}" \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_PREFIX_PATH=$PREFIX \
    -D CMAKE_INSTALL_PREFIX=$PREFIX \
    -B build -S $SRC_DIR

# Build and install
cmake --build build --target install
