mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DPYTHON_DEST=$SP_DIR \
      -DBUILD_SWIG_PYTHON:BOOL=ON \
      "-DCMAKE_BUILD_TYPE=Release" \
      $SRC_DIR
make -j${CPU_COUNT}
make install
