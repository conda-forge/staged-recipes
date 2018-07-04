case `uname` in
    Darwin|Linux)
        export CFLAGS="$CFLAGS -I$PREFIX/include"
        export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
        ./configure --prefix=$PREFIX x86_64
        ;;
    MINGW*)
        export CFLAGS="$CFLAGS -I$LIBRARY_PREFIX/include"
        export LDFLAGS="$LDFLAGS -L$LIBRARY_PREFIX/lib"
        ./configure --disable-shared --prefix=$LIBRARY_PREFIX x86_64
        ;;
esac

make -j${CPU_COUNT}
make install
make check -j${CPU_COUNT}
