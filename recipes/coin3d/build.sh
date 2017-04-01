cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      .

make -j2 2>&1 | tee output.txt
make -j2 install

# Certain apps, like pivy, need coin-config. Cmake does not yet generate the coin-default.cfg
mkdir build-cfg -p
cd build-cfg
../configure --prefix=$PREFIX --without-framework --enable-3ds-import --disable-dependency-tracking
make coin-default.cfg

mkdir -p $PREFIX/share/Coin/conf/
cp coin-default.cfg $PREFIX/share/Coin/conf/
cp ${SRC_DIR}/bin/coin-config ${PREFIX}/bin/
