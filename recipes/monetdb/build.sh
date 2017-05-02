CFLAGS="-I$CONDA_PREFIX/include $CFLAGS"
LDFLAGS="-L$CONDA_PREFIX/lib -Wl,-rpath,$CONDA_PREFIX/lib $LDFLAGS"

./configure \
    pcre_CFLAGS="$CFLAGS" \
    pcre_LIBS="$LDFLAGS -lpcre" \
    libxml2_CFLAGS="$CFLAGS -I$CONDA_PREFIX/include/libxml2" \
    libxml2_LIBS="$LDFLAGS" \
    CFLAGS="$CFLAGS" \
    LDFLAGS="$LDFLAGS" \
    LIBS="-liconv -lxml2" \
    --enable-optimize \
    --with-readline=$CONDA_PREFIX \
    --with-bz2=$CONDA_PREFIX \
    --with-libiconv-prefix=$CONDA_PREFIX \
    --enable-pyintegration \
    --with-pyversion=$PYTHON \
    --with-pyconfig=$CONDA_PREFIX/bin/python$PY_VER-config \
    --enable-rintegration \
    --prefix=$PREFIX

make

make install
