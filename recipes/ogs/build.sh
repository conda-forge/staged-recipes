#!/bin/sh
set -ex

if [[ "${target_platform}" == osx-* ]]; then
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

mkdir build
cd build
cmake -LAH -G Ninja ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DCMAKE_PREFIX_PATH=${PREFIX} \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_INSTALL_RPATH=${PREFIX}/lib \
    -DOGS_BUILD_TESTING=OFF \
    -DOGS_VERSION=${PKG_VERSION} \
    -DOGS_INSTALL_DEPENDENCIES=OFF \
    -DOGS_CPU_ARCHITECTURE=OFF \
    -DBUILD_SHARED_LIBS=ON \
    -DCONDA_BUILD=ON \
    ..

cmake --build . --target install -j${CPU_COUNT}

