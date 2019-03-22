#!/bin/bash

if [ `uname` == Darwin ]; then
    CMAKE_ARGS="-D CMAKE_OSX_DEPLOYMENT_TARGET:STRING=${MACOSX_DEPLOYMENT_TARGET}"
fi

BUILD_DIR=${SRC_DIR}/build
mkdir ${BUILD_DIR}
cd ${BUILD_DIR}

cmake \
    -G Ninja \
    -D "CMAKE_CXX_FLAGS:STRING=-fvisibility=hidden -fvisibility-inlines-hidden ${CXXFLAGS}" \
    -D "CMAKE_C_FLAGS:STRING=-fvisibility=hidden ${CFLAGS}" \
    -D CMAKE_BUILD_TYPE:STRING=Release \
    ${CMAKE_ARGS} \
    -D SimpleITK_BUILD_DISTRIBUTE:BOOL=ON \
    -D SimpleITK_BUILD_STRIP:BOOL=ON \
    -D SimpleITK_EXPLICIT_INSTANTIATION:BOOL=ON \
    -D CMAKE_BUILD_TYPE:STRING=RELEASE \
    -D BUILD_SHARED_LIBS:BOOL=OFF \
    -D BUILD_TESTING:BOOL=OFF \
    -D BUILD_EXAMPLES:BOOL=OFF \
    -D WRAP_DEFAULT:BOOL=OFF \
    -D "CMAKE_SYSTEM_PREFIX_PATH:FILEPATH=${PREFIX}" \
    "${SRC_DIR}"

cmake --build  . --config Release
cmake \
    -D CMAKE_INSTALL_PREFIX=$PREFIX \
    -P ${BUILD_DIR}/cmake_install.cmake

