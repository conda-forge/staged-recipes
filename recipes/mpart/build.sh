#!/bin/bash

PYTHON_INCLUDE_DIR=$($PYTHON -c 'import distutils.sysconfig, sys; sys.stdout.write(distutils.sysconfig.get_python_inc())')
PYTHON_LIBRARY=$($PYTHON -c 'from distutils.sysconfig import get_config_var; import os, sys; sys.stdout.write(os.path.join(get_config_var("LIBDIR"),get_config_var("LDLIBRARY")))')

# Build MParT
mkdir build; cd build

cmake \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DEigen3_ROOT=$PREFIX/include \
    -DKokkos_ENABLE_PTHREAD=ON \
    -DKokkos_ENABLE_SERIAL=ON \
    -DMPART_PYTHON=ON \
    -DMPART_JULIA=OFF \
    -DMPART_MATLAB=OFF \
    -DMPART_BUILD_TESTS=OFF \
    -DPYTHON_INCLUDE_DIR=$PYTHON_INCLUDE_DIR \
    -DPYTHON_LIBRARY=$PYTHON_LIBRARY \
    -DPYTHON_EXECUTABLE=$PYTHON \
    -DCMAKE_INCLUDE_PATH=$PREFIX/include \
    -DCMAKE_OSX_ARCHITECTURES=x86_64 \
    $SRC_DIR

make -j$CPU_COUNT
make install
