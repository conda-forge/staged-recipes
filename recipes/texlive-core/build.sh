#! /bin/bash

# kpathsea scans the texmf.cnf file to set up its hardcoded paths, so set them
# up before building. It doesn't seem to handle multivalued TEXMFCNF entries,
# so we patch that up after install.

mv $SRC_DIR/texk/kpathsea/texmf.cnf tmp.cnf
sed \
    -e "s|TEXMFROOT =.*|TEXMFROOT = $PREFIX/share/texlive|" \
    -e "s|TEXMFLOCAL =.*|TEXMFLOCAL = $PREFIX/share/texlive/texmf-local|" \
    -e "/^TEXMFCNF/,/^}/d" \
    -e "s|%TEXMFCNF =.*|TEXMFCNF = $PREFIX/share/texlive/texmf-dist/web2c|" \
    <tmp.cnf >$SRC_DIR/texk/kpathsea/texmf.cnf
rm -f tmp.cnf

export PKG_CONFIG_LIBDIR="$PREFIX/lib/pkgconfig:$PREFIX/share/pkgconfig"

# We need to package graphite2 to be able to use it harfbuzz.
# Using our cairo breaks the recipe and `mpfr` is not found triggering the library from TL tree.

mkdir -p tmp_build && pushd tmp_build
  ../configure --prefix=$PREFIX \
               --datarootdir="$PREFIX/share/texlive" \
               --disable-all-pkgs \
               --disable-native-texlive-build \
               --disable-ipc \
               --disable-debug \
               --disable-dependency-tracking \
               --disable-mf \
               --disable-pmp \
               --disable-upmp \
               --disable-aleph \
               --disable-eptex \
               --disable-euptex \
               --disable-luatex \
               --disable-luajittex \
               --disable-uptex \
               --enable-web2c \
               --enable-silent-rules \
               --enable-tex \
               --enable-etex \
               --enable-pdftex \
               --enable-xetex \
               --enable-web-progs \
               --enable-texlive \
               --enable-dvipdfm-x \
               --with-system-icu \
               --with-icu-includes=$PREFIX/include \
               --with-icu-libdir=$PREFIX/lib \
               --with-system-gmp \
               --with-gmp-includes=$PREFIX/include \
               --with-gmp-libdir=$PREFIX/lib \
               --with-system-pixman \
               --with-system-freetype2 \
               --with-system-libpng \
               --with-system-zlib \
               --with-zlib-includes=$PREFIX/include \
               --with-zlib-libdir=$PREFIX/lib \
               --with-sytem-mpfr \
               --with-mpfr-includes=$PREFIX/include \
               --with-mprf-libdir=$PREFIX/lib \
               --without-system-harfbuzz \
               --without-system-graphite2 \
               --without-system-poppler \
               --without-system-cairo
  make
  LC_ALL=C make check
  make install
popd

# Remove info and man pages.
rm -rf $PREFIX/share/man
rm -rf $PREFIX/share/texlive/info

mv $PREFIX/share/texlive/texmf-dist/web2c/texmf.cnf tmp.cnf
sed \
    -e "s|TEXMFCNF =.*|TEXMFCNF = {$PREFIX/share/texlive/texmf-local/web2c, $PREFIX/share/texlive/texmf-dist/web2c}|" \
    <tmp.cnf >$PREFIX/share/texlive/texmf-dist/web2c/texmf.cnf
rm -f tmp.cnf
