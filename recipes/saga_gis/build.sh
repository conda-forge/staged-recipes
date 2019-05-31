autoreconf -fi
bash configure --enable-python PYTHON=$PYTHON --prefix=$PREFIX
make
make install