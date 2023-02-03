#!/bin/bash

# Install to conda style directories
[[ -d lib64 ]] && mv lib64 lib
mkdir -p ${PREFIX}/cuda-compat

cp lib/libcuda.so.${PKG_VERSION} ${PREFIX}/cuda-compat
ln -s libcuda.so.${PKG_VERSION} ${PREFIX}/cuda-compat/libcuda.so.1
ln -s libcuda.so.1 ${PREFIX}/cuda-compat/libcuda.so
cp lib/libnvidia-nvvm.so.${PKG_VERSION} ${PREFIX}/cuda-compat
ln -s libnvidia-nvvm.so.${PKG_VERSION} ${PREFIX}/cuda-compat/libnvidia-nvvm.so.4
ln -s libnvidia-nvvm.so.4 ${PREFIX}/cuda-compat/libnvidia-nvvm.so
cp lib/libnvidia-ptxjitcompiler.so.${PKG_VERSION} ${PREFIX}/cuda-compat
ln -s libnvidia-ptxjitcompiler.so.${PKG_VERSION} ${PREFIX}/cuda-compat/libnvidia-ptxjitcompiler.so.1
cp lib/libcudadebugger.so.${PKG_VERSION} ${PREFIX}/cuda-compat
ln -s libcudadebugger.so.${PKG_VERSION} ${PREFIX}/cuda-compat/libcudadebugger.so.1
