#!/bin/bash

CMAKE_FLAGS="-DCMAKE_INSTALL_PREFIX=$PREFIX -DBUILD_TESTING=OFF"

# Ensure we build a release
CMAKE_FLAGS+=" -DCMAKE_BUILD_TYPE=Release"

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    #
    # For Docker build
    #

    # JDC test
    echo "PATH: $PATH"
    env | sort

    # CFLAGS
    export MINIMAL_CFLAGS="-g -O3"
    export CFLAGS="$MINIMAL_CFLAGS"
    export CXXFLAGS="$MINIMAL_CFLAGS"
    export LDFLAGS="$LDPATHFLAGS"

    # Use clang 3.8.1 from the clangdev package on conda-forge
    # CMAKE_FLAGS+=" -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++"

    # OpenMM build configuration
    CUDA_PATH="/usr/local/cuda"
    CMAKE_FLAGS+=" -DCUDA_TOOLKIT_ROOT_DIR=${CUDA_PATH}/"
    # AMD APP SDK 3.0 OpenCL
    CMAKE_FLAGS+=" -DOPENCL_INCLUDE_DIR=${CUDA_PATH}/include/"
    CMAKE_FLAGS+=" -DOPENCL_LIBRARY=${CUDA_PATH}/lib64/libOpenCL.so"
    # CUDA OpenCL
    #CMAKE_FLAGS+=" -DOPENCL_INCLUDE_DUR=${CUDA_PATH}/include/"
    #CMAKE_FLAGS+=" -DOPENCL_LIBRARY=${CUDA_PATH}/lib64/libOpenCL.so"
    # gcc from devtoolset-2
    #CMAKE_FLAGS+=" -DCMAKE_CXX_LINK_FLAGS=-Wl,-rpath,/opt/rh/devtoolset-2/root/usr/lib64" # JDC test
    #CMAKE_FLAGS+=" -DCMAKE_CXX_FLAGS=--gcc-toolchain=/opt/rh/devtoolset-2/root/usr/"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # conda-build MACOSX_DEPLOYMENT_TARGET must be exported as an environment variable to override 10.7 default
    # cc: https://github.com/conda/conda-build/pull/1561
    export MACOSX_DEPLOYMENT_TARGET="10.13"
    CMAKE_FLAGS+=" -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++"
    CMAKE_FLAGS+=" -DCMAKE_OSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET}"
    CMAKE_FLAGS+=" -DCUDA_TOOLKIT_ROOT_DIR=/Developer/NVIDIA/CUDA-${CUDA_VERSION}/"
    CMAKE_FLAGS+=" -DCUDA_LIBRARY_DIR=/usr/local/cuda/lib" # DEBUG
    #CMAKE_FLAGS+=" -DCUDA_CUDA_LIBRARY=/usr/local/cuda/lib/libcudart.dylib" # DEBUG
    CMAKE_FLAGS+=" -DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX${MACOSX_DEPLOYMENT_TARGET}.sdk"
fi

# Generate API docs
CMAKE_FLAGS+=" -DOPENMM_GENERATE_API_DOCS=ON"

# Set location for FFTW3 on both linux and mac
CMAKE_FLAGS+=" -DFFTW_INCLUDES=$PREFIX/include"
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    CMAKE_FLAGS+=" -DFFTW_LIBRARY=$PREFIX/lib/libfftw3f.so"
    CMAKE_FLAGS+=" -DFFTW_THREADS_LIBRARY=$PREFIX/lib/libfftw3f_threads.so"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    CMAKE_FLAGS+=" -DFFTW_LIBRARY=$PREFIX/lib/libfftw3f.dylib"
    CMAKE_FLAGS+=" -DFFTW_THREADS_LIBRARY=$PREFIX/lib/libfftw3f_threads.dylib"
fi

# DEBUG
echo "CMAKE_FLAGS:"
echo $CMAKE_FLAGS

# Build in subdirectory and install.
mkdir build
cd build
cmake .. $CMAKE_FLAGS
make -j$CPU_COUNT all

# PythonInstall uses the gcc/g++ 4.2.1 that anaconda was built with, so we can't add extraneous unrecognized compiler arguments.
#export CXXFLAGS="$MINIMAL_CFLAGS"
#export LDFLAGS="$LDPATHFLAGS"
#export SHLIB_LDFLAGS="$LDPATHFLAGS"

make -j$CPU_COUNT install PythonInstall

# Clean up paths for API docs.
mkdir openmm-docs
mv $PREFIX/docs/* openmm-docs
mv openmm-docs $PREFIX/docs/openmm

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    # Add GLIBC_2.14 for pdflatex
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/glibc-2.14/lib
fi

# DEBUG: Needed for latest sphinx
#locale -a
#export LC_ALL=C
#locale -a

# Build PDF manuals
#make -j$CPU_COUNT sphinxpdf
#mv sphinx-docs/userguide/latex/*.pdf $PREFIX/docs/openmm/
#mv sphinx-docs/developerguide/latex/*.pdf $PREFIX/docs/openmm/

# Put examples into an appropriate subdirectory.
mkdir $PREFIX/share/openmm/
mv $PREFIX/examples $PREFIX/share/openmm/