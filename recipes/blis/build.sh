case `uname` in
    Darwin)
    Linux)
        export CFLAGS="$CFLAGS -I$PREFIX/include"
        export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
        ./configure x86_64 --prefix=$PREFIX
        ;;
    MINGW*)
        export CFLAGS="$CFLAGS -I$LIBRARY_PREFIX/include"
        export LDFLAGS="$LDFLAGS -L$LIBRARY_PREFIX/lib"
        ./configure x86_64 --disable-shared --prefix=$LIBRARY_PREFIX
        ;;
esac

make -j${CPU_COUNT}
make install

