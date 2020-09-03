git submodule init
git submodule update third_party/minigun

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
      -DIS_CONDA_BUILD=ON \
      ..

# cmake --build . -- -j${CPU_COUNT}
cmake --build . -- -j1

cd ../python
$PYTHON -m pip install . --no-deps --ignore-installed -vvv
