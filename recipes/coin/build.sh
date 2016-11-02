cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      .

make -j4 2>&1 | tee output.txt
make -j4 install
