mkdir build
cd build

cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
      -DDEAL_II_ALLOW_BUNDLED=OFF \
      -DBOOST_DIR="${PREFIX}" \
      -DTBB_DIR="${PREFIX}" \
      -DMUPARSER_DIR="${PREFIX}" \
      ..

make -j${CPU_COUNT}
make install
make test
