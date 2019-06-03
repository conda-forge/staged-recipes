ln -s $CXX $BUILD_PREFIX/bin/c++
bash configure --enable-python PYTHON=$PYTHON --prefix=$PREFIX
make
make install