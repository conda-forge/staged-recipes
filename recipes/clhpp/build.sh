#!/bin/bash

cp "${RECIPE_DIR}/LICENSE.txt" "${SRC_DIR}/LICENSE.txt"

mkdir build_release
cd build_release


OPENCL_DIST_DIR_FLAG="-DOPENCL_DIST_DIR=${PREFIX}"
if [[ "`uname`" == "Darwin" ]] && [[ "${OSX_VARIANT}" == "native" ]]
then
    OPENCL_DIST_DIR_FLAG="";
fi

cmake \
    -G "Unix Makefiles" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}/include" \
    -DBUILD_DOCS=0 \
    -DBUILD_EXAMPLES=0 \
    -DBUILD_TESTS=0 \
    "${OPENCL_DIST_DIR_FLAG}" \
    "${SRC_DIR}"
make
make install
