mkdir -p build

pushd build

cmake \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CONFIGURATION_TYPES="Release" \
      -DUSE_LLVM=ON \
      -DUSE_CUDA=OFF \
      ..

make -j$CPU_COUNT
make install

popd

pushd python
$PYTHON setup.py install
popd

pushd topi/python
$PYTHON setup.py install
popd

pushd nnvm/python
$PYTHON setup.py install
popd

