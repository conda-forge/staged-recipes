
./bootstrap.sh

./configure --prefix=$PREFIX \
            --enable-applications \
            --enable-all \
            --enable-openmp \
            --with-fftw3-libdir=$PREFIX/lib \
            --with-fftw3-includedir=$PREFIX/include \
            --with-window=kaiserbessel
# --with-gcc-arch=
# --with-apple-gcc-arch=

make
make check
make install
