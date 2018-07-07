#!/bin/bash

set -ex

echo "Building cudatoolkit ..."

filename="cuda_${PKG_VERSION}"
install_dir=$CONDA_PREFIX/tmp/cuda

mkdir -p $install_dir
mkdir -p $PREFIX/{lib,include}

chmod ugo+x $filename
./$filename --silent --toolkit --toolkitpath=$install_dir --override

echo "Removing unnecessary folders"
excluded_dirs="bin doc extras jre libnsight libnvvp nsightee_plugins nvml pkgconfig samples tools"
for f in $excluded_dirs
do
    rm -rf $install_dir/$f
done

cuda_libs="libcudart libcudart_static libcudadevrt"
cuda_libs+=" libcufft libcufft_static libcufftw libcufftw_static"
cuda_libs+=" libcublas libcublas_static libcublas_device"
cuda_libs+=" libnvblas"
cuda_libs+=" libcusparse libcusparse_static"
cuda_libs+=" libcusolver libcusolver_static"
cuda_libs+=" libcurand libcurand_static"
cuda_libs+=" libnvgraph libnvgraph_static"
cuda_libs+=" libnppc libnppc_static libnppial libnppial_static"
cuda_libs+=" libnppicc libnppicc_static libnppicom"
cuda_libs+=" libnppicom_static libnppidei libnppidei_static" 
cuda_libs+=" libnppif libnppif_static libnppig libnppig_static"
cuda_libs+=" libnppim libnppim_static libnppist libnppist_static"
cuda_libs+=" libnppisu libnppisu_static libnppitc"
cuda_libs+=" libnppitc_static libnpps libnpps_static"
cuda_libs+=" libculibos"
cuda_libs+=" libnvrtc libnvrtc-builtins"
cuda_libs+=" libnvvm"
cuda_libs+=" libdevice.10.bc"
cuda_libs+=" libcupti"
cuda_libs+=" libnvToolsExt"

cuda_h="cuda_occupancy.h"

echo "Copying lib files:"
for f in $cuda_libs
do
    echo "- $f ..."
    find $install_dir -name "${f}*"  -exec cp -a {} $PREFIX/lib \;
done

echo "Copying header files:"
for f in $cuda_h
do
    echo "- $f ..."
    find $install_dir -name "${f}*"  -exec cp -a {} $PREFIX/include \;
done

echo "Removing installation folder"
rm -rf $install_dir
