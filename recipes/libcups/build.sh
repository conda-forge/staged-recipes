if [[ "$target_platform" == linux* ]]; then
    export LIBS="-lrt"
fi

./configure --prefix=$PREFIX --with-components=core
make -j${CPU_COUNT}
#fails due to some network issue
#make check
make install
