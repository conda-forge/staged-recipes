#!/bin/bash
export MAKEFLAGS="-j$(nproc)"
echo "nproc = '$(nproc)'"
if [[ "${cuda_compiler_version}" == "None" ]]
then
  $PYTHON -m pip install . -vv --install-option="-DRPU_BLAS=MKL"
else
  $PYTHON -m pip install . -vv --install-option="-DRPU_BLAS=MKL" --install-option="-DUSE_CUDA=ON" --install-option="-DRPU_CUDA_ARCHITECTURES='60;61;70;75;80;86'"    --install-option="-DCUDAHOSTCXX=$CXX" --install-option="-DCMAKE_CUDA_COMPILER=`which nvcc`" --install-option="-DCMAKE_CUDA_HOST_COMPILER=${CXX}"
fi
