#!/bin/bash
set -e

opt=""

if [[ "$TRAVIS_OS_NAME" == "osx" ]]; then
  opt="-DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT} -DGMX_EXTERNAL_BLAS=on"
fi

plumed-patch -p --runtime -e gromacs-2018.6
mkdir build
cd build
cmake .. \
  $opt \
  -DGMX_DEFAULT_SUFFIX=ON \
  -DGMX_MPI=OFF \
  -DGMX_GPU=OFF \
  -DGMX_SIMD=SSE2 \
  -DCMAKE_PREFIX_PATH=$PREFIX \
  -DCMAKE_INSTALL_PREFIX=$PREFIX
make -j $CPU_COUNT
make install
