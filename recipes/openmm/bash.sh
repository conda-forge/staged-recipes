#!/bin/bash

CMAKE_FLAGS="-DCMAKE_INSTALL_PREFIX=$PREFIX -DBUILD_TESTING=OFF"

# Ensure we build a release
CMAKE_FLAGS+=" -DCMAKE_BUILD_TYPE=Release"

CUDA_VERSION="8.0"

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    #
    # For Docker build
    #

    # Fix hbb issues.
    # If statements needed because multiple Python versions are built in same docker image.
    if [ ! -e /opt/rh/devtoolset-2/root/usr/lib/gcc/x86_64-redhat-linux ]; then
        ln -s /opt/rh/devtoolset-2/root/usr/lib/gcc/x86_64-CentOS-linux/ /opt/rh/devtoolset-2/root/usr/lib/gcc/x86_64-redhat-linux
    fi
    if [ ! -e /opt/rh/devtoolset-2/root/usr/include/c++/4.8.2/x86_64-redhat-linux ]; then
        ln -s /opt/rh/devtoolset-2/root/usr/include/c++/4.8.2/x86_64-CentOS-linux/ /opt/rh/devtoolset-2/root/usr/include/c++/4.8.2/x86_64-redhat-linux
    fi

    # Clang paths
    export CLANG_PREFIX="/opt/clang"
    export PATH=$PATH:$CLANG_PREFIX/bin

    # enable devtoolset-2
    # will return an error return code because of python 3.x incompatible code, but this error is inconsequential
    #source /opt/rh/devtoolset-2/enable || true
    export PATH=/opt/rh/devtoolset-2/root/usr/bin${PATH:+:${PATH}}
    export MANPATH=/opt/rh/devtoolset-2/root/usr/share/man:$MANPATH
    export INFOPATH=/opt/rh/devtoolset-2/root/usr/share/info${INFOPATH:+:${INFOPATH}}
    export PCP_DIR=/opt/rh/devtoolset-2/root
    # Some perl Ext::MakeMaker versions install things under /usr/lib/perl5
    # even though the system otherwise would go to /usr/lib64/perl5.
    export PERL5LIB=/opt/rh/devtoolset-2/root//usr/lib64/perl5/vendor_perl/5.8.8/x86_64-linux-thread-multi:/opt/rh/devtoolset-2/root/usr/lib/perl5:/opt/rh/devtoolset-2/root//usr/lib/perl5/vendor_perl/5.8.8${PERL5LIB:+:${PERL5LIB}}
    # bz847911 workaround:
    # we need to evaluate rpm's installed run-time % { _libdir }, not rpmbuild time
    # or else /etc/ld.so.conf.d files?
    rpmlibdir=`rpm --eval "%{_libdir}"`
    # bz1017604: On 64-bit hosts, we should include also the 32-bit library path.
    if [ "$rpmlibdir" != "${rpmlibdir/lib64/}" ]; then
      rpmlibdir32=":/opt/rh/devtoolset-2/root${rpmlibdir/lib64/lib}"
    fi
    export LD_LIBRARY_PATH=/opt/rh/devtoolset-2/root$rpmlibdir$rpmlibdir32${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
    # duplicate python site.py logic for sitepackages
    pythonvers=`python -c 'import sys; print(sys.version[:3])'`
    export PYTHONPATH=/opt/rh/devtoolset-2/root/usr/lib64/python$pythonvers/site-packages:/opt/rh/devtoolset-2/root/usr/lib/python$pythonvers/site-packages${PYTHONPATH:+:${PYTHONPATH}}

    # CFLAGS
    export MINIMAL_CFLAGS="-g -O3"
    export CFLAGS="$MINIMAL_CFLAGS"
    export CXXFLAGS="$MINIMAL_CFLAGS"
    export LDFLAGS="$LDPATHFLAGS"

    # Use clang 3.8.1 inside omnia-build-box docker image
    CMAKE_FLAGS+=" -DCMAKE_C_COMPILER=$CLANG_PREFIX/bin/clang -DCMAKE_CXX_COMPILER=$CLANG_PREFIX/bin/clang++"

    # OpenMM build configuration
    CUDA_PATH="/usr/local/cuda-${CUDA_VERSION}"
    CMAKE_FLAGS+=" -DCUDA_CUDART_LIBRARY=${CUDA_PATH}/lib64/libcudart.so"
    CMAKE_FLAGS+=" -DCUDA_NVCC_EXECUTABLE=${CUDA_PATH}/bin/nvcc"
    CMAKE_FLAGS+=" -DCUDA_SDK_ROOT_DIR=${CUDA_PATH}/"
    CMAKE_FLAGS+=" -DCUDA_TOOLKIT_INCLUDE=${CUDA_PATH}/include"
    CMAKE_FLAGS+=" -DCUDA_TOOLKIT_ROOT_DIR=${CUDA_PATH}/"
    CMAKE_FLAGS+=" -DCMAKE_CXX_FLAGS_RELEASE=-I/usr/include/nvidia/"
    # AMD APP SDK 3.0 OpenCL
    CMAKE_FLAGS+=" -DOPENCL_INCLUDE_DIR=/opt/AMDAPPSDK-3.0/include/"
    CMAKE_FLAGS+=" -DOPENCL_LIBRARY=/opt/AMDAPPSDK-3.0/lib/x86_64/libOpenCL.so"
    # CUDA OpenCL
    #CMAKE_FLAGS+=" -DOPENCL_INCLUDE_DUR=${CUDA_PATH}/include/"
    #CMAKE_FLAGS+=" -DOPENCL_LIBRARY=${CUDA_PATH}/lib64/libOpenCL.so"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    CMAKE_FLAGS+=" -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++"
    CMAKE_FLAGS+=" -DCMAKE_OSX_DEPLOYMENT_TARGET=10.9"
    CMAKE_FLAGS+=" -DCUDA_SDK_ROOT_DIR=/Developer/NVIDIA/CUDA-${CUDA_VERSION}"
    CMAKE_FLAGS+=" -DCUDA_TOOLKIT_ROOT_DIR=/Developer/NVIDIA/CUDA-${CUDA_VERSION}"
    CMAKE_FLAGS+=" -DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk"
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

# Build in subdirectory and install.
mkdir build
cd build
cmake .. $CMAKE_FLAGS
make -j$CPU_COUNT all

# PythonInstall uses the gcc/g++ 4.2.1 that anaconda was built with, so we can't add extraneous unrecognized compiler arguments.
export CXXFLAGS="$MINIMAL_CFLAGS"
export LDFLAGS="$LDPATHFLAGS"
export SHLIB_LDFLAGS="$LDPATHFLAGS"

make -j$CPU_COUNT install PythonInstall

# Clean up paths for API docs.
mkdir openmm-docs
mv $PREFIX/docs/* openmm-docs
mv openmm-docs $PREFIX/docs/openmm

# Build PDF manuals
# make -j$CPU_COUNT sphinxpdf
# mv sphinx-docs/userguide/latex/*.pdf $PREFIX/docs/openmm/
# mv sphinx-docs/developerguide/latex/*.pdf $PREFIX/docs/openmm/

# Put examples into an appropriate subdirectory.
mkdir $PREFIX/share/openmm/
mv $PREFIX/examples $PREFIX/share/openmm/
