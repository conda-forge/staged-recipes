# from https://github.com/grosskur/gmp-rpm/blob/master/gmp.spec
./configure --prefix=$PREFIX \
            --libdir=$PREFIX/lib \
            -enable-cxx

make -j5
make install
