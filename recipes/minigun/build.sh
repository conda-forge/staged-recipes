mkdir -p build

pushd build

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DUSE_CUDA=ON \
      -DBUILD_SAMPLES=OFF \
      ..

make -j$CPU_COUNT
make install
