git submodule init
git submodule update --recursive

mkdir build
cd build

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_BUILD_TYPE="Release" \
      -DUSE_CUDA=OFF \
      -DUSE_OPENMP=ON \
      -DBUILD_CPP_TEST=OFF \
      -DUSE_S3=OFF \
      -DUSE_HDFS=OFF \
      -DCUDA_ARCH_NAME=All ..

cmake --build . -- -j${CPU_COUNT}

cd ../python
$PYTHON -m pip install . --no-deps --ignore-installed -vvv


cmake -DCMAKE_BUILD_TYPE="Release" \
      -DUSE_CUDA=OFF \
      -DUSE_OPENMP=ON \
      -DBUILD_CPP_TEST=OFF \
      -DUSE_S3=OFF \
      -DUSE_HDFS=OFF \
      -DIS_CONDA_BUILD=ON \
      ..
