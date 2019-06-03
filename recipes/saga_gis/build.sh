alias c++='g++'
bash configure --enable-python PYTHON=$PYTHON --prefix=$PREFIX
make
make install