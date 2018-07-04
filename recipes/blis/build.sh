case `uname` in
    Darwin)
        ln -s $CC $BUILD_PREFIX/clang
        export CC=$BUILD_PREFIX/clang
        export CFLAGS="$CFLAGS -I$PREFIX/include"
        export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
        ./configure --prefix=$PREFIX x86_64
        make CC_VENDOR=clang -j${CPU_COUNT}
        make install
        make check -j${CPU_COUNT}
        ;;
    Linux)
        ln -s $CC $BUILD_PREFIX/gcc
        export CC=$BUILD_PREFIX/gcc
        export CFLAGS="$CFLAGS -I$PREFIX/include"
        export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
        ./configure --prefix=$PREFIX x86_64
        make CC_VENDOR=gcc -j${CPU_COUNT}
        make install
        make check -j${CPU_COUNT}
        ;;
    MINGW*)
        export PATH=$BUILD_PREFIX/Library/bin:$PATH
        export CC=$BUILD_PREFIX/clang
        export RANLIB=echo
        export CFLAGS="$CFLAGS -I$LIBRARY_PREFIX/include"
        export LDFLAGS="$LDFLAGS -L$LIBRARY_PREFIX/lib"
        ./configure --disable-shared --prefix=$LIBRARY_PREFIX x86_64
        make CPICFLAGS= -j${CPU_COUNT}
        make install
        make check CPICFLAGS= -j${CPU_COUNT}
        mv $LIBRARY_PREFIX/lib/libblis.a $LIBRARY_PREFIX/lib/blis.lib
        ;;
esac
