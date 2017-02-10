#!/bin/bash

export CPPFLAGS="-I$PREFIX/include $CPPFLAGS"
export LDFLAGS="-L$PREFIX/lib $LDFLAGS"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export CFLAGS="-g -O3 -fPIC $CFLAGS"

# Following is adapted from https://github.com/sagemath/sage

VERSION=$PKG_VERSION
echo $VERSION
GAP_DIR="gap-$VERSION"
INSTALL_DIR="$PREFIX/gap/$GAP_DIR"

# Delete PDF documentation and misc TeX files
find doc \( \
         -name "*.bbl" \
      -o -name "*.blg" \
      -o -name "*.aux" \
      -o -name "*.dvi" \
      -o -name "*.idx" \
      -o -name "*.ilg" \
      -o -name "*.l*" \
      -o -name "*.m*" \
      -o -name "*.pdf" \
      -o -name "*.ind" \
      -o -name "*.toc" \
      \) -exec rm {} \;

# DATABASES (to be separated out to database_gap-feedstock) except GAPDoc which is required:
rm -rf small prim trans
cd pkg
shopt -s extglob
rm -rf !(GAPDoc*)
cd ..

chmod +x configure

./configure \
    --prefix="$PREFIX" PREFIX="$PREFIX" \
    --with-gmp="$PREFIX" \
    CC="$CC" CXX="$CXX" CFLAGS="$CFLAGS" CXXFLAGS="$CXXFLAGS"


make config
make

mkdir -p "$INSTALL_DIR" &&
cp -R * "$INSTALL_DIR"
ln -s "$GAP_DIR" "$PREFIX/gap/latest"
cp bin/gap.sh "$PREFIX/bin/gap"

# Delete tests that rely on the non-GPL small group library
rm "$INSTALL_DIR"/tst/testinstall/ctblsolv.tst
rm "$INSTALL_DIR"/tst/testinstall/grppc.tst
rm "$INSTALL_DIR"/tst/testinstall/morpheus.tst

