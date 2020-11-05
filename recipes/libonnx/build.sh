export ONNX_ML=0
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX
cmake --build .
cmake --build . --target install

