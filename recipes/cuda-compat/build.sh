#!/bin/bash

# Install to conda style directories
[[ -d lib64 ]] && mv lib64 lib
mkdir -p ${PREFIX}/cuda-compat

cp -v lib/libcuda.so.${DRV_VERSION} ${PREFIX}/cuda-compat
ln -sv libcuda.so.${DRV_VERSION} ${PREFIX}/cuda-compat/libcuda.so.1
ln -sv libcuda.so.1 ${PREFIX}/cuda-compat/libcuda.so
cp -v lib/libnvidia-nvvm.so.${DRV_VERSION} ${PREFIX}/cuda-compat
ln -sv libnvidia-nvvm.so.${DRV_VERSION} ${PREFIX}/cuda-compat/libnvidia-nvvm.so.4
ln -sv libnvidia-nvvm.so.4 ${PREFIX}/cuda-compat/libnvidia-nvvm.so
cp -v lib/libnvidia-ptxjitcompiler.so.${DRV_VERSION} ${PREFIX}/cuda-compat
ln -sv libnvidia-ptxjitcompiler.so.${DRV_VERSION} ${PREFIX}/cuda-compat/libnvidia-ptxjitcompiler.so.1
cp -v lib/libcudadebugger.so.${DRV_VERSION} ${PREFIX}/cuda-compat
ln -sv libcudadebugger.so.${DRV_VERSION} ${PREFIX}/cuda-compat/libcudadebugger.so.1
