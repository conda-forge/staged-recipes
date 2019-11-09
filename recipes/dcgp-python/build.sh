#!/usr/bin/env bash

mkdir build
cd build

if [[ "$target_platform" == linux-64 ]]; then
    LDFLAGS="-lrt ${LDFLAGS}"
fi

# Install the dcgp headers first.
cmake \
    -DBoost_NO_BOOST_CMAKE=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DDCGP_BUILD_TESTS=no \
    -DDCGP_BUILD_EXAMPLES=no \
    ..

make -j${CPU_COUNT} VERBOSE=1

make install

cd ..
mkdir build_python
cd build_python

# Now the python bindings.
cmake \
    -DBoost_NO_BOOST_CMAKE=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DDCGP_BUILD_DCGP=no \
    -DDCGP_BUILD_DCGPY=yes \
    ..

make -j${CPU_COUNT} VERBOSE=1

make install
