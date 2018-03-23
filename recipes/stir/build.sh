mkdir build && cd build
cmake -D CMAKE_INSTALL_PREFIX=$PREFIX \
      -D PYTHON_DEST=$SP_DIR \
      -D BUILD_SWIG_PYTHON:BOOL=ON \
      -D CMAKE_BUILD_TYPE=Release \
      $SRC_DIR
make -j${CPU_COUNT}
make install
