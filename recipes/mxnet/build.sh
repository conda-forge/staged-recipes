set -x

#!/usr/bin/env bash

set -ex

# Use the OpenMP library already in the environment
rm -rf 3rdparty/openmp/

# Use the MKL-DNN library already in the environment
# rm -rf 3rdparty/mkldnn
# rm -rf include/mkldnn

export OPENMP_OPT=ON
#export JEMALLOC_OPT=ON

if [[ "$OSTYPE" == "darwin"* ]]; then
  export OPENMP_OPT=OFF
  PLATFORM=darwin
  # On macOS, jemalloc defaults to JEMALLOC_PREFIX: 'je_'
  # for which mxnet source code isn't ready yet.
#  export JEMALLOC_OPT=OFF
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  PLATFORM=linux
fi

cmake_config=config/distribution/${PLATFORM}_${mxnet_variant_str}.cmake
if [[ ! -f $cmake_config ]]; then
  >&2 echo "Couldn't find cmake config $cmake_config for the current settings."
  exit 1
fi

if [[ ! -f /usr/local/cuda-10.2/targets/x86_64-linux/include/cublas_v2.h ]]; then
  ln -s /usr/include/cublas_v2.h /usr/local/cuda-10.2/targets/x86_64-linux/include/cublas_v2.h
fi

declare -a _gpu_opts
if [[ ${mxnet_variant_str} =~ .*cu.* ]]; then
  _gpu_opts+=(-DUSE_CUDA=ON)
  _gpu_opts+=(-DUSE_CUDNN=ON)
  _gpu_opts+=(-DUSE_CUDA_PATH=/usr/local/cuda-${cudatoolkit_version})
  _gpu_opts+=(-DCMAKE_CUDA_COMPILER=/usr/local/cuda-${cuda_compiler_version}/bin/nvcc)
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64/stubs
else
  _gpu_opts+=(-DUSE_CUDA=OFF)
  _gpu_opts+=(-DUSE_CUDNN=OFF)
fi

cp $cmake_config config.cmake

rm -rf build
mkdir build
cd build
cmake -GNinja "${_gpu_opts[@]}" ..
ninja
cd ..

# remove static libs
rm -f build/libmxnet.a

cd python
$PYTHON setup.py install --with-cython --single-version-externally-managed --record=record.txt
