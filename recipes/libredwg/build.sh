autoreconf --install --symlink -I m4

case `uname` in
    Darwin|Linux)
        export CFLAGS="-O3 -g -fPIC $CFLAGS"
        ./configure --prefix="$PREFIX" --libdir="$PREFIX"/lib --disable-sse2
        ;;
    MINGW*)
        export PATH="$PREFIX/Library/bin:$BUILD_PREFIX/Library/bin:$RECIPE_DIR:$PATH"
        export CFLAGS="-MD -I$PREFIX/Library/include -O2 -DM4RI_USE_DLL"
        export LDFLAGS="$LDFLAGS -L$PREFIX/Library/lib"
        ./configure --prefix="$PREFIX/Library" --libdir="$PREFIX/Library/lib" --disable-sse2
        ;;
esac

make
make install