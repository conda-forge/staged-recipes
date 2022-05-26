#!/bin/bash

CMAKE_ARGS="$CMAKE_ARGS -DCMAKE_BUILD_TYPE=Release -DOPENMM_DIR=$PREFIX"

if [[ "$target_platform" == linux* ]]; then
    # CFLAGS
    MINIMAL_CFLAGS+=" -O3 -ldl"
    CFLAGS+=" $MINIMAL_CFLAGS"
    CXXFLAGS+=" $MINIMAL_CFLAGS"
    LDFLAGS+=" $LDPATHFLAGS"

    # Use GCC
    CMAKE_ARGS+=" -DCMAKE_C_COMPILER=$CC -DCMAKE_CXX_COMPILER=$CXX"

    # CUDA_HOME is defined by nvcc metapackage
    CMAKE_ARGS+=" -DCUDA_TOOLKIT_ROOT_DIR=${CUDA_HOME}"
    CMAKE_ARGS+=" -DCMAKE_LIBRARY_PATH=${CUDA_HOME}/lib64/stubs"
    CMAKE_ARGS+=" -DCUDA_CUDA_LIBRARY=${CUDA_HOME}/lib64/stubs/libcuda.so"
fi

mkdir build
cd build
cmake ${CMAKE_ARGS} ${SRC_DIR}
make -j $CPU_COUNT
make install PythonInstall

for lib in ${PREFIX}/lib/plugins/*${SHLIB_EXT}; do
    ln -s $lib ${PREFIX}/lib/$(basename $lib) || true
done
