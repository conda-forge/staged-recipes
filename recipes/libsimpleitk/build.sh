#!/bin/bash

# When building 32-bits on 64-bit system this flags is not automatically set by conda-build
if [ $ARCH == 32 -a "${OSX_ARCH:-notosx}" == "notosx" ]; then
    export CFLAGS="${CFLAGS} -m32"
    export CXXFLAGS="${CXXFLAGS} -m32"
fi

if [ -z "${OSX_ARCH+x}" ]; then
    export CXXFLAGS="${CXXFLAGS} -std=c++11"
fi

BUILD_DIR=${SRC_DIR}/build
mkdir ${BUILD_DIR}
cd ${BUILD_DIR}

cmake \
    -G Ninja \
    -D "CMAKE_CXX_FLAGS:STRING=-fvisibility=hidden -fvisibility-inlines-hidden ${CXXFLAGS}" \
    -D "CMAKE_C_FLAGS:STRING=-fvisibility=hidden ${CFLAGS}" \
    -D "CMAKE_EXE_LINKER_FLAGS:STRING=${LDFLAGS}" \
    -D "CMAKE_MODULE_LINKER_FLAGS:STRING=${LDFLAGS}" \
    -D "CMAKE_SHARED_LINKER_FLAGS:STRING=${LDFLAGS}" \
    -D "CMAKE_STATIC_LINKER_FLAGS:STRING=${LDFLAGS}" \
    ${CMAKE_ARGS} \
    -D SimpleITK_BUILD_DISTRIBUTE:BOOL=ON \
    -D CMAKE_BUILD_TYPE:STRING=RELEASE \
    -D BUILD_SHARED_LIBS:BOOL=ON \
    -D BUILD_TESTING:BOOL=OFF \
    -D BUILD_EXAMPLES:BOOL=OFF \
    -D WRAP_DEFAULT:BOOL=OFF \
    -D SimpleITK_EXPLICIT_INSTANTIATION:BOOL=OFF \
    -D "CMAKE_SYSTEM_PREFIX_PATH:FILEPATH=${PREFIX}" \
    -D "CMAKE_INSTALL_PREFIX=$PREFIX" \
    ..


ninja -j $((${CPU_COUNT}))
cmake \
    -D CMAKE_INSTALL_DO_STRIP:BOOL=1 \
    -D CMAKE_INSTALL_PREFIX=$PREFIX \
    -P ${BUILD_DIR}/cmake_install.cmake
