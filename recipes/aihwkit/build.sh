#!/bin/bash
if [[ "${aihwkit_variant}" == "cpu" ]]
then 
  $PYTHON -m pip install . -vv -C "-DRPU_BLAS=OpenBLAS"
elif [[ "${aihwkit_variant}" == "gpu" ]]
then
  $PYTHON -m pip install . -vv -C "-DRPU_BLAS=OpenBLAS" -C "-DUSE_CUDA=ON" -C "-DRPU_CUDA_ARCHITECTURES='35;50;60;61;70;75;80;86'"    -C "-DCUDAHOSTCXX=$CXX" -C "-DCMAKE_CUDA_COMPILER=`which nvcc`" -C "-DCMAKE_CUDA_HOST_COMPILER=${CXX}"
else
  echo "aihwkit_variant was set to '$aihwkit_variant', an invalid value."
  echo "aihwkit_variant must be set to either 'cpu' or 'gpu'."
fi
