mkdir $SRC_DIR/build && cd $SRC_DIR/build
cmake $SRC_DIR -D CMAKE_INSTALL_PREFIX=$PREFIX/bin
echo "CXX_INCLUDES = -I $SRC_DIR/build/generated -isystem $PREFIX/include" >> $SRC_DIR/build/CMakeFiles/clustering.dir/flags.make

make
make install