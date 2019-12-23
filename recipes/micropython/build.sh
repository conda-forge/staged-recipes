if [ `uname` == Darwin ]; then
    sed -i '' 's/gcc/\$\(GCC\)/g' $SRC_DIR/py/mkenv.mk
else
    sed -i 's/gcc/\$\(GCC\)/g' $SRC_DIR/py/mkenv.mk
fi

cd $SRC_DIR/lib
rm -rf axtls libffi berkeley-db-1.xx
wget https://github.com/pfalcon/axtls/archive/43a6e6bd3bbc03dc501e16b89fba0ef042ed3ea0.zip
wget https://github.com/atgreen/libffi/archive/e9de7e35f2339598b16cbb375f9992643ed81209.zip
wget https://github.com/pfalcon/berkeley-db-1.xx/archive/35aaec4418ad78628a3b935885dd189d41ce779b.zip
unzip 43a6e6bd3bbc03dc501e16b89fba0ef042ed3ea0.zip
unzip e9de7e35f2339598b16cbb375f9992643ed81209.zip
unzip 35aaec4418ad78628a3b935885dd189d41ce779b.zip
mv axtls-43a6e6bd3bbc03dc501e16b89fba0ef042ed3ea0 axtls
mv libffi-e9de7e35f2339598b16cbb375f9992643ed81209 libffi
mv berkeley-db-1.xx-35aaec4418ad78628a3b935885dd189d41ce779b berkeley-db-1.xx

cd $SRC_DIR/mpy-cross
CFLAGS_EXTRA="$CFLAGS" CPP="$GCC -E" make

cd $SRC_DIR/ports/unix
if [ `uname` == Darwin ]; then
    sed -i '' '/GIT_SUBMODULES/d' Makefile
    LDFLAGS_EXTRA="-lrt" CFLAGS_EXTRA="$CFLAGS" CPP="$GCC" make
else
    sed -i '/GIT_SUBMODULES/d' Makefile
    LDFLAGS_EXTRA="-lrt" CFLAGS_EXTRA="$CFLAGS" CPP="$GCC -E" make
fi

mv micropython $PREFIX/bin
