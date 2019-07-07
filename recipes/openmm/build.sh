#!/bin/bash

CMAKE_FLAGS="-DCMAKE_INSTALL_PREFIX=$PREFIX -DBUILD_TESTING=OFF"

# Ensure we build a release
CMAKE_FLAGS+=" -DCMAKE_BUILD_TYPE=Release"

echo "PATH: $PATH"
env
# CFLAGS
export MINIMAL_CFLAGS="-g -O3"
export CFLAGS="$MINIMAL_CFLAGS"
export CXXFLAGS="$MINIMAL_CFLAGS"
export LDFLAGS="$LDPATHFLAGS"
# Use clang 3.8.1 from the clangdev package on conda-forge
CMAKE_FLAGS+=" -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++"
CMAKE_FLAGS+=" -DCMAKE_CXX_FLAGS=--gcc-toolchain=/opt/rh/devtoolset-2/root/usr/"


# Generate API docs
CMAKE_FLAGS+=" -DOPENMM_GENERATE_API_DOCS=ON"

# Set location for FFTW3 on both linux and mac
CMAKE_FLAGS+=" -DFFTW_INCLUDES=$PREFIX/include"
CMAKE_FLAGS+=" -DFFTW_LIBRARY=$PREFIX/lib/libfftw3f.so"
CMAKE_FLAGS+=" -DFFTW_THREADS_LIBRARY=$PREFIX/lib/libfftw3f_threads.so"

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

# Add GLIBC_2.14 for pdflatex
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/glibc-2.14/lib

# DEBUG: Needed for latest sphinx
locale -a
export LC_ALL=C
#export LC_ALL="en_US.UTF-8"
#export LC_CTYPE="en_US.UTF-8"
locale -a
#sudo dpkg-reconfigure locales

# Build PDF manuals
make -j$CPU_COUNT sphinxpdf
mv sphinx-docs/userguide/latex/*.pdf $PREFIX/docs/openmm/
mv sphinx-docs/developerguide/latex/*.pdf $PREFIX/docs/openmm/

# Put examples into an appropriate subdirectory.
mkdir $PREFIX/share/openmm/
mv $PREFIX/examples $PREFIX/share/openmm/
