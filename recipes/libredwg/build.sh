echo "####################################"
echo $(ls -al)
echo "####################################"

# TODO: Fix this upstream
mv git-version-gen build-aux/git-version-gen
chmod +x build-aux/git-version-gen

autoreconf --install
chmod +x configure


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

make -j${CPU_COUNT}
make install
