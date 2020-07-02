mkdir build
cd build

cmake .. -G Ninja \
         -DCMAKE_PREFIX_PATH=$PREFIX \
         -DCMAKE_BUILD_TYPE=Release \
         -DCMAKE_INSTALL_PREFIX=$PREFIX \
         -DCMAKE_INCLUDE_PATH=$PREFIX/include \
         -DDLPACK_PATH=$PREFIX/include \
         -DDMLC_PATH=$PREFIX/include \
         -DRANG_PATH=$PREFIX/include \
         -DUSE_CUDA=OFF \
         -DUSE_VULKAN=OFF

         
ninja -j${CPU_COUNT}
ninja install


cd ../python
$PYTHON setup.py install
cd ..

cd topi/python
$PYTHON setup.py install
