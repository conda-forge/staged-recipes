mkdir build; cd $_

export CFLAGS=-fPIC
export CXXFLAGS=-fpic
export LDFLAGS="-L$PREFIX/lib -lmpi $LDFLAGS"

echo '#!/usr/bin/env perl' > ../config/token-replace_new.pl
tail -n +2 ../config/token-replace.pl >> ../config/token-replace_new.pl
mv ../config/token-replace_new.pl ../config/token-replace.pl
chmod a+x ../config/token-replace.pl
../configure --prefix=$PREFIX --srcdir=$SRC_DIR

make -j${CPU_COUNT}
make test
make install
