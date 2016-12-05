cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      .

make -j4 2>&1 | tee output.txt
make -j4 install

cp -r ${RECIPE_DIR}/Coin ${PREFIX}/share/
cp ${SRC_DIR}/bin/coin-config ${PREFIX}/bin/