#!/bin/bash

PYTHON_INCLUDE_DIR=$($PYTHON -c 'import distutils.sysconfig, sys; sys.stdout.write(distutils.sysconfig.get_python_inc())')
PYTHON_LIBRARY=$($PYTHON -c 'from distutils.sysconfig import get_config_var; import os, sys; sys.stdout.write(os.path.join(get_config_var("LIBDIR"),get_config_var("LDLIBRARY")))')

cd build

cmake \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DPYTHON_INSTALL_PREFIX=$SP_DIR \
    -DMUQ_BOOST_DIR=$PREFIX \
    -DMUQ_EIGEN3_DIR=$PREFIX/include \
    -DMUQ_HDF5_DIR=$PREFIX \
    -DMUQ_NANOFLANN_DIR=$PREFIX \
    -DMUQ_SUNDIALS_DIR=$PREFIX \
    -DMUQ_NLOPT_DIR=$PREFIX \
    -DMUQ_NANOFLANN_DIR=$PREFIX \
    -DMUQ_USE_PYTHON=ON \
    -DPYTHON_INCLUDE_DIR=$PYTHON_INCLUDE_DIR \
    -DPYTHON_LIBRARY=$PYTHON_LIBRARY \
    -DPYTHON_EXECUTABLE=$PYTHON \
    -DCMAKE_INCLUDE_PATH=$PREFIX/include \
    $SRC_DIR

make -j$CPU_COUNT
make install
