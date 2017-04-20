#!/bin/bash

# When building 32-bits on 64-bit system this flags is not automatically set by conda-build
if [ $ARCH == 32 -a "${OSX_ARC:-notosx}" == "notosx" ]; then
    export CFLAGS="${CFLAGS} -m32"
    export CXXFLAGS="${CXXFLAGS} -m32"
fi

BUILD_DIR=${SRC_DIR}/build
mkdir ${BUILD_DIR}
cd ${BUILD_DIR}


cmake \
    -G "Ninja" \
    ${CMAKE_ARGS} \
    -D BUILD_SHARED_LIBS:BOOL=OFF \
    -D BUILD_TESTING:BOOL=ON \
    -D BUILD_EXAMPLES:BOOL=OFF \
    -D ITK_USE_SYSTEM_EXPAT:BOOL=ON \
    -D ITK_USE_SYSTEM_HDF5:BOOL=ON \
    -D ITK_USE_SYSTEM_JPEG:BOOL=ON \
    -D ITK_USE_SYSTEM_PNG:BOOL=ON \
    -D ITK_USE_SYSTEM_TIFF:BOOL=ON \
    -D ITK_USE_SYSTEM_ZLIB:BOOL=ON \
    -D ITK_LEGACY_REMOVE:BOOL=ON \
    -D ITK_USE_KWSTYLE:BOOL=OFF \
    -D ITK_BUILD_DEFAULT_MODULES:BOOL=ON\
    -D Module_ITKReview:BOOL=ON \
    -D CMAKE_BUILD_TYPE:STRING=RELEASE \
    -D "CMAKE_SYSTEM_PREFIX_PATH:FILEPATH=${PREFIX}" \
    -D "CMAKE_INSTALL_PREFIX=${PREFIX}" \
    "${SRC_DIR}"

ninja -j $((${CPU_COUNT}+1))

cmake \
    -D CMAKE_INSTALL_PREFIX=$PREFIX \
    -P ${BUILD_DIR}/cmake_install.cmake


