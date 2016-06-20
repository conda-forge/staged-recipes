#!/bin/bash

# FIXME: This is a hack to make sure the environment is activated.
# The reason this is required is due to the conda-build issue
# mentioned below.
#
# https://github.com/conda/conda-build/issues/910
#
source activate "${CONDA_DEFAULT_ENV}"

export CFLAGS="-fPIC ${CFLAGS}"
export CXXFLAGS="-fPIC ${CXXFLAGS}"

if [ "$(uname)" == "Darwin" ]
then
    export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
else
    export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
fi

mkdir build
cd build
cmake ..\
        -DCMAKE_C_COMPILER="${CC}" \
        -DCMAKE_CXX_COMPILER="${CXX}" \
        -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
        -DCMAKE_INSTALL_LIBDIR="${PREFIX}/lib" \
        -DCMAKE_PREFIX_PATH="${PREFIX}" \
        -DCMAKE_C_FLAGS="${CFLAGS}" \
        -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
        -DBUILD_STATIC_LIBS=1 \
        -DBUILD_SHARED_LIBS=1 \
        -DCMAKE_SHARED_LINKER_FLAGS="${LDFLAGS}" \
        -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" \
        -DPYTHON_EXECUTABLE="${PYTHON}"

make
eval ${LIBRARY_SEARCH_VAR}=$PREFIX/lib make jsoncpp_check
make install
