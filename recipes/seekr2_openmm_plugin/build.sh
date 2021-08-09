#!/bin/bash

CMAKE_FLAGS="-DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_BUILD_TYPE=Release -DSEEKR2_BUILD_OPENCL_LIB=OFF -DOPENMM_DIR=$PREFIX"

if [[ "$target_platform" == linux* ]]; then
    # CFLAGS
    # JRG: Had to add -ldl to prevent linking errors (dlopen, etc)
    MINIMAL_CFLAGS+=" -O3 -ldl"
    CFLAGS+=" $MINIMAL_CFLAGS"
    CXXFLAGS+=" $MINIMAL_CFLAGS"
    LDFLAGS+=" $LDPATHFLAGS"

    # Use GCC
    CMAKE_FLAGS+=" -DCMAKE_C_COMPILER=$CC -DCMAKE_CXX_COMPILER=$CXX"

    # CUDA_HOME is defined by nvcc metapackage
    CMAKE_FLAGS+=" -DCUDA_TOOLKIT_ROOT_DIR=${CUDA_HOME}"
    # From: https://github.com/floydhub/dl-docker/issues/59
    CMAKE_FLAGS+=" -DCMAKE_LIBRARY_PATH=${CUDA_HOME}/lib64/stubs"
    
fi

# Build in subdirectory and install.
mkdir build
cd build
cmake ${CMAKE_FLAGS} ${SRC_DIR}/seekr2plugin
make
make install PythonInstall

for lib in ${PREFIX}/lib/plugins/*${SHLIB_EXT}; do
    ln -s $lib ${PREFIX}/lib/$(basename $lib) || true
done
