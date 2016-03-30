# Install single precision
./configure --prefix=$PREFIX --exec-prefix=$PREFIX --enable-shared --disable-static --enable-single
make
make install
# Install double precision
./configure --prefix=$PREFIX --exec-prefix=$PREFIX --enable-shared --disable-static
make
make install

