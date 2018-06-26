#!/bin/bash

cmake \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DENABLE_SWIG_JAVA=false \
    -DENABLE_SWIG_MATLAB=false \
    -DENABLE_SWIG_OCTAVE=false \
    -DENABLE_SWIG_PYTHON=true \
    -DPYTHON_NUMPY_INCLUDE_PATH=${SP_DIR}/numpy/core/include \
    -DPYTHON_MODULE_INSTALL_DIR=${SP_DIR} \
    -DPYTHON_EXTMODULE_INSTALL_DIR=${SP_DIR}

cmake --build .
cmake --build . -- install
