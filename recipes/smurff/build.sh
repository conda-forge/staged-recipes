#!/bin/bash

export CMAKE_ARGS="-DENABLE_MKL=ON -DCMAKE_INSTALL_PREFIX=$PREFIX -DENABLE_MPI=OFF"

# make sure we use CONDA_BUILD_SYSROOT
# https://github.com/conda/conda-build/issues/3452#issuecomment-47539707
[[ ${target_platform} == "osx-64" ]] && \
    CMAKE_ARGS="$CMAKE_ARGS -DCMAKE_OSX_SYSROOT=${CONDA_BUILD_SYSROOT}"

$PYTHON setup.py install \
    --install-binaries \
    --single-version-externally-managed --record=record.txt