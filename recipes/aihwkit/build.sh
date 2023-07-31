#!/bin/bash
if [[ "${aihwkit_variant}" == "cpu" ]]
then 
  $PYTHON -m pip install . -vv --install-option="-DRPU_BLAS=MKL"
elif [[ "${aihwkit_variant}" == "gpu" ]]
then
  $PYTHON -m pip install . -vv --install-option="-DRPU_BLAS=MKL" --install-option="-DUSE_CUDA=ON" --install-option="-DRPU_CUDA_ARCHITECTURES='60;61;70;75;80;86'"    --install-option="-DCUDAHOSTCXX=$CXX" --install-option="-DCMAKE_CUDA_COMPILER=`which nvcc`" --install-option="-DCMAKE_CUDA_HOST_COMPILER=${CXX}"
else
  echo "aihwkit_variant was set to '$aihwkit_variant', an invalid value."
  echo "aihwkit_variant must be set to either 'cpu' or 'gpu'."
fi
