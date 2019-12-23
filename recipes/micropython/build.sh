if [ `uname` != Darwin ]; then
    sed -i 's/gcc/\$\(GCC\)/g' $SRC_DIR/py/mkenv.mk
fi

cd $SRC_DIR/lib
sha=(
    43a6e6bd3bbc03dc501e16b89fba0ef042ed3ea0
    e9de7e35f2339598b16cbb375f9992643ed81209
    35aaec4418ad78628a3b935885dd189d41ce779b
)
library=(
    axtls
    libffi
    berkeley-db-1.xx
)
name=(
    pfalcon
    atgreen
    pfalcon
)
for i in ${!library[@]}; do
    rmdir ${library[$i]}
    wget https://github.com/${name[$i]}/${library[$i]}/archive/${sha[$i]}.zip
    unzip ${sha[$i]}.zip
    mv ${library[$i]}-${sha[$i]} ${library[$i]}
done

cd $SRC_DIR/mpy-cross
export CFLAGS_EXTRA="$CFLAGS"
export CPP="$CC -E"
make -j${CPU_COUNT}

cd $SRC_DIR/ports/unix
if [ `uname` != Darwin ]; then
    export LDFLAGS_EXTRA="-lrt"
fi
make -j${CPU_COUNT}

mv micropython $PREFIX/bin
