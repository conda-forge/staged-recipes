#!/bin/bash

mkdir build_release
cd build_release


OPENCL_ROOT_FLAG="-DOPENCL_ROOT=${PREFIX}"
if [[ "`uname`" == "Darwin" ]] && [[ "${OSX_VARIANT}" == "native" ]]
then
    OPENCL_ROOT_FLAG="";
fi

CFLAGS="${CFLAGS} -I${PREFIX}/include"
CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include"

cmake \
    -G "Unix Makefiles" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DclSPARSE_BUILD64=1 \
    -DUSE_SYSTEM_CL2HPP=1 \
    -DSUFFIX_BIN="" \
    -DSUFFIX_LIB="" \
    -DBUILD_TESTS=0 \
    "${OPENCL_ROOT_FLAG}" \
    "${SRC_DIR}/src"

make
make install
