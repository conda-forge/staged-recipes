CONDA_CFLAGS="-I$CONDA_PREFIX/include"
CONDA_LDFLAGS="-L$CONDA_PREFIX/lib -Wl,-rpath,$CONDA_PREFIX/lib"

./configure \
    pcre_CFLAGS="$CONDA_CFLAGS" \
    pcre_LIBS="$CONDA_LDFLAGS -lpcre" \
    libxml2_CFLAGS="$CONDA_CFLAGS -I$CONDA_PREFIX/include/libxml2" \
    libxml2_LIBS="$CONDA_LDFLAGS" \
    CFLAGS="$CONDA_CFLAGS" \
    LDFLAGS="$CONDA_LDFLAGS" \
    LIBS="-liconv -lxml2" \
    --with-readline=$CONDA_PREFIX \
    --with-libiconv-prefix=$CONDA_PREFIX \
    --prefix=$PREFIX \

make

make install
