#!/bin/bash

export CMAKE_ARGS="${CMAKE_ARGS} -DENABLE_BLAS=ON -DCMAKE_INSTALL_PREFIX=$PREFIX -DENABLE_MPI=OFF"


$PYTHON setup.py install \
    --install-binaries \
    --single-version-externally-managed --record=record.txt
