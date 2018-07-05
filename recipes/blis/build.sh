case `uname` in
    Darwin)
        export CC=$BUILD_PREFIX/bin/clang
        export CFLAGS="$CFLAGS -I$PREFIX/include"
        export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
        ./configure --prefix=$PREFIX --enable-cblas --enable-threading=pthreads x86_64
        make CC_VENDOR=clang -j${CPU_COUNT}
        make install
        make check -j${CPU_COUNT}
        ;;
    Linux)
        ln -s `which $CC` $BUILD_PREFIX/bin/gcc
        export CC=$BUILD_PREFIX/bin/gcc
        export CFLAGS="$CFLAGS -I$PREFIX/include"
        export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
        ./configure --prefix=$PREFIX --enable-cblas --enable-threading=pthreads x86_64
        make CC_VENDOR=gcc -j${CPU_COUNT}
        make install
        make check -j${CPU_COUNT}
        ;;
    MINGW*)
        export PATH="$PREFIX/Library/bin:$BUILD_PREFIX/Library/bin:$PATH"
        export CC=clang
        export RANLIB=echo
        export LIBPTHREAD=-lpthreads
        export AS=llvm-as
        export CFLAGS="-MD -I$PREFIX/Library/include"
        export LDFLAGS="$LDFLAGS -L$PREFIX/Library/lib"
        clang --version
        llvm-as --version
        llvm-ar --version
        # TODO: change intel64->x86_64 when ARG_MAX issue is fixed.
        ./configure --disable-shared --prefix=$PREFIX/Library --enable-cblas --enable-threading=pthreads intel64
        make CPICFLAGS= LIBPTHREAD=-lpthreads AR=llvm-ar LIBM= -j${CPU_COUNT}
        make install
        make check CPICFLAGS= LIBPTHREAD=-lpthreads AR=llvm-ar LIBM= -j${CPU_COUNT}
        mv $PREFIX/Library/lib/libblis.a $PREFIX/Library/lib/blis.lib
        ;;
esac
