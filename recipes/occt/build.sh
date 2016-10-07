mkdir build
cd build

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DUSE_TCL=NO \
      -BUILD_MODULE_DRAW=NO \
      ..

make -j2 2>&1 | tee output.txt
make -j2 install
