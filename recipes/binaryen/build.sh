#!/bin/bash

export CMAKE_CONFIG="Release"

EXTRA_CMAKE_ARGS=""
if [[ `uname` == 'Darwin' ]];
then
    EXTRA_CMAKE_ARGS="-DCMAKE_MACOSX_RPATH:BOOL=ON"
fi
export EXTRA_CMAKE_ARGS

mkdir "build_${CMAKE_CONFIG}"
pushd "build_${CMAKE_CONFIG}"
cmake -G "Ninja" \
    -DCMAKE_BUILD_TYPE:STRING="${CMAKE_CONFIG}" \
    -DCMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
    -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DCMAKE_MACOSX_RPATH:BOOL=ON \
    ${EXTRA_CMAKE_ARGS} \
    "${SRC_DIR}"
ninja
ninja install
popd

# Needs Emscripten and other stuff to work.
#pushd "${SRC_DIR}"
#$PYTHON ./check.py
#popd
