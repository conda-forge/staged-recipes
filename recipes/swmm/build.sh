cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX CMakeLists.txt
cmake --build . --config Release
# cmake --install $SRC_DIR -v
mkdir -p $PREFIX/bin $PREFIX/lib
install $SRC_DIR/bin/run-swmm $PREFIX/bin
ls $SRC_DIR/lib/
if [ $(uname) == Darwin ]; then
  install $SRC_DIR/lib/*.dylib $PREFIX/lib
else
  install $SRC_DIR/lib/*.so $PREFIX/lib
fi
