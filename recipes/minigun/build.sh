mkdir -p build

pushd build

CUDA_SUPPORT="OFF"
CUDA_CMAKE_OPTIONS=""
if [[ $1 == "gpu" ]]; then
    CUDA_SUPPORT="ON"
    CUDA_CMAKE_OPTIONS="-DCUDA_TOOLKIT_ROOT_DIR=${CUDA_HOME}"
fi

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DUSE_CUDA=${CUDA_SUPPORT} ${CUDA_CMAKE_OPTIONS} \
      -DBUILD_SAMPLES=OFF \
      -DCMAKE_BUILD_TYPE="Release" \
      ..

cmake --build .
cmake --install .
