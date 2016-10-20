cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_BINARY_DIR=$PREFIX \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      .

make -j2 2>&1 | tee output.txt
make -j2 install
