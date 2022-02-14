#!/usr/bin/env bash

export INSTALL_PREFIX=${CONDA_PREFIX}
ln -s /usr/local/cuda/lib64/stubs/libcuda.so /usr/local/cuda/lib64/stubs/libcuda.so.1
export LD_LIBRARY_PATH=/usr/local/cuda/lib64/stubs/:$LD_LIBRARY_PATH

cd ${SRC_DIR}/rmm/python

$PYTHON setup.py build_ext --inplace
$PYTHON setup.py install

rm /usr/local/cuda/lib64/stubs/libcuda.so.1
