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
    CMAKE_FLAGS+=" -DCUDA_CUDA_LIBRARY=$CUDA_HOME/lib64/stubs/libcuda.so"
    
fi

# Build in subdirectory and install.
ls $CUDA_HOME/lib64/stubs
echo "setting soft link"
#sudo ln -s /lib64/libcuda.so /lib64/libcuda.so.1
ln -s /lib64/libcuda.so ${PREFIX}/lib/libcuda.so.1
#echo "ls /lib64"
#ls /lib64/
echo "ls ${PREFIX}/lib"
ls ${PREFIX}/lib

export LD_LIBRARY_PATH=$CUDA_HOME/lib64/stubs:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=${PREFIX}/lib/:$LD_LIBRARY_PATH

mkdir build
cd build
cmake ${CMAKE_FLAGS} ${SRC_DIR}/seekr2plugin
make
make install PythonInstall

for lib in ${PREFIX}/lib/plugins/*${SHLIB_EXT}; do
    ln -s $lib ${PREFIX}/lib/$(basename $lib) || true
done
