#!/bin/bash
set -ex

cd cpp/

if [[ ${cuda_compiler_version} != "None" ]]; then
  export KATAGO_BACKEND="CUDA"
  export USE_CUDA=1
  export NCCL_ROOT_DIR=$PREFIX
  export NCCL_INCLUDE_DIR=$PREFIX/include
  export USE_SYSTEM_NCCL=1
  export USE_STATIC_NCCL=0
  export USE_STATIC_CUDNN=0
  export CUDA_TOOLKIT_ROOT_DIR=$CUDA_HOME
  export CUDNN_INCLUDE_DIR=$PREFIX/include
else
  export KATAGO_BACKEND="EIGEN"
  export USE_CUDA=0
fi

cmake ${CMAKE_ARGS} . \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=TRUE \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DUSE_BACKEND=${KATAGO_BACKEND} \
  -DNO_GIT_REVISION=1 \
  -DUSE_AVX2=1

make -j $CPU_COUNT

# Install binary
mkdir -p "${PREFIX}/bin/"
cp ./katago "${PREFIX}/bin/katago"
chmod +x "${PREFIX}/bin/katago"

# Install config files
KATAGO_VAR_DIR="${PREFIX}/var/katago/"
mkdir -p $KATAGO_VAR_DIR
cp -R ./configs/ $KATAGO_VAR_DIR

# Install NN files
KATAGO_WEIGTHS_DIR="${KATAGO_VAR_DIR}/weights/"
KATAGO_WEIGTHS_NAME="kata1-b40c256-s11840935168-d2898845681.bin.gz"
curl https://media.katagotraining.org/uploaded/networks/models/kata1/${KATAGO_WEIGTHS_NAME} --output ${KATAGO_WEIGTHS_NAME}
mkdir -p $KATAGO_WEIGTHS_DIR
cp $KATAGO_WEIGTHS_NAME "${KATAGO_WEIGTHS_DIR}/${KATAGO_WEIGTHS_NAME}"
