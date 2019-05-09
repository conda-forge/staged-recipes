mkdir -p build

pushd build

export DMLC_CORE_PATH=$PREFIX
export DLPACK_PATH=$PREFIX


cmake \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CONFIGURATION_TYPES="Release" \
      -DUSE_LLVM=ON \
      -DUSE_CUDA=OFF \
      -DUSE_OPENGL=ON \
      -DUSE_VULKAN=OFF \
      -DCMAKE_VERBOSE_MAKEFILE=ON \
      ..

make -j$CPU_COUNT VERBOSE=1
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

