mkdir -p build
cd build

cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      -DCMAKE_PREFIX_PATH=${PREFIX} \
      -DCMAKE_BUILD_TYPE=Release \
      -DSYMFORCE_BUILD_EXAMPLES=OFF \
      -DSYMFORCE_BUILD_TEST=OFF \
      -DSYMFORCE_ADD_PYTHON_TEST=OFF \
      ..

make -j${CPU_COUNT}
make install
