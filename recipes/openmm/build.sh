#!/bin/bash
CMAKE_FLAGS="-DCMAKE_INSTALL_PREFIX=$PREFIX -DBUILD_TESTING=OFF"

# Ensure we build a release
CMAKE_FLAGS+=" -DCMAKE_BUILD_TYPE=Release"

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    # CFLAGS
    MINIMAL_CFLAGS+=" -g -O3 -ldl"
    CFLAGS+=" $MINIMAL_CFLAGS"
    CXXFLAGS+=" $MINIMAL_CFLAGS"
    LDFLAGS+=" $LDPATHFLAGS"

    # FIXME? We should use this line below, but this prevents CUDA and pthreads from being found!
    # From https://docs.conda.io/projects/conda-build/en/latest/resources/compiler-tools.html#an-aside-on-cmake-and-sysroots
    # CMAKE_FLAGS+=" -DCMAKE_TOOLCHAIN_FILE=${RECIPE_DIR}/cross-linux.cmake"

    # Use GCC
    CMAKE_FLAGS+=" -DCMAKE_C_COMPILER=$CC -DCMAKE_CXX_COMPILER=$CXX"

    # OpenMM build configuration
    # CUDA_HOME is defined by nvcc metapackage
    CMAKE_FLAGS+=" -DCUDA_TOOLKIT_ROOT_DIR=${CUDA_HOME}"
    # From: https://github.com/floydhub/dl-docker/issues/59
    CMAKE_FLAGS+=" -DCMAKE_LIBRARY_PATH=${CUDA_HOME}/lib64/stubs"
    # CUDA tests won't build, disable for now
    # See https://github.com/openmm/openmm/issues/2258#issuecomment-462223634
    CMAKE_FLAGS+=" -DOPENMM_BUILD_CUDA_TESTS=OFF"

    # CUDA OpenCL
    CMAKE_FLAGS+=" -DOPENCL_INCLUDE_DIR=${CUDA_HOME}/include/"
    CMAKE_FLAGS+=" -DOPENCL_LIBRARY=${CUDA_HOME}/lib64/libOpenCL.so"

elif [[ "$OSTYPE" == "darwin"* ]]; then
    # conda-build MACOSX_DEPLOYMENT_TARGET must be exported as an environment variable to override 10.7 default
    # cc: https://github.com/conda/conda-build/pull/1561
    export MACOSX_DEPLOYMENT_TARGET="10.13"
    CMAKE_FLAGS+=" -DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT}"
    CMAKE_FLAGS+=" -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++"
    CMAKE_FLAGS+=" -DCMAKE_OSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET}"
    CMAKE_FLAGS+=" -DCUDA_TOOLKIT_ROOT_DIR=/Developer/NVIDIA/CUDA-${CUDA_VER}/"
    CMAKE_FLAGS+=" -DCUDA_LIBRARY_DIR=/Developer/NVIDIA/CUDA-${CUDA_VER}/lib" # DEBUG
    #CMAKE_FLAGS+=" -DCUDA_CUDA_LIBRARY=/Developer/NVIDIA/CUDA-${CUDA_VER}/lib/libcudart.dylib" # DEBUG
fi

# Set location for FFTW3 on both linux and mac
CMAKE_FLAGS+=" -DFFTW_INCLUDES=${PREFIX}/include/"
CMAKE_FLAGS+=" -DFFTW_LIBRARY=${PREFIX}/lib/libfftw3f${SHLIB_EXT}"
CMAKE_FLAGS+=" -DFFTW_THREADS_LIBRARY=${PREFIX}/lib/libfftw3f_threads${SHLIB_EXT}"


# DEBUG
env | sort
echo "CMAKE_FLAGS:"
echo $CMAKE_FLAGS


# Build in subdirectory and install.
mkdir build
cd build
cmake ${CMAKE_FLAGS} ${SRC_DIR}
make -j$CPU_COUNT
make -j$CPU_COUNT install PythonInstall

# Put examples into an appropriate subdirectory.
mkdir $PREFIX/share/openmm/
mv $PREFIX/examples $PREFIX/share/openmm/