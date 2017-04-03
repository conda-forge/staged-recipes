CFLAGS="-I$CONDA_PREFIX/include"
LDFLAGS="-L$CONDA_PREFIX/lib -Wl,-rpath,$CONDA_PREFIX/lib"

./configure \
    pcre_CFLAGS="$CFLAGS" \
    pcre_LIBS="$LDFLAGS -lpcre" \
    libxml2_CFLAGS="$CFLAGS -I$CONDA_PREFIX/include/libxml2" \
    libxml2_LIBS="$LDFLAGS" \
    CFLAGS="$CFLAGS" \
    LDFLAGS="$LDFLAGS" \
    LIBS="-liconv -lxml2" \
    --with-readline=$CONDA_PREFIX \
    --with-libiconv-prefix=$CONDA_PREFIX \
    --prefix=$PREFIX \

make

make install
