#!/bin/bash

export CPPFLAGS="-I$PREFIX/include -DDISABLE_COMMENTATOR $CPPFLAGS"
export LDFLAGS="-L$PREFIX/lib $LDFLAGS"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export CFLAGS="-O2 -g -fPIC $CFLAGS"
export CXXFLAGS="-O2 -g -fPIC $CXXFLAGS"

chmod +x configure

./configure \
    --prefix="$PREFIX" \
    --libdir="$PREFIX/lib" \
    --bindir="$PREFIX/bin" \
    --exec-prefix="$PREFIX" \
    --with-default="$PREFIX" \
    --with-gmp="$PREFIX" \
    --with-flint="$PREFIX" \
    --with-ntl="$PREFIX" \
    --enable-gfanlib \
    --enable-Singular \
    --enable-factory \
    --disable-doc

make -j${CPU_COUNT}
make check
make install

# Fix all Singular includes to work from PREFIX/include
cd "$PREFIX/include"

# First, generate a sed script to do these replacements
find singular -name '*.h' | while read include; do
    # Replace #include <foo> by #include <singular/foo>
    echo "s|# *include .${include#singular/}.|#include <$include>|"
done >"$SRC_DIR/fix_includes.sed"

# Now execute the script (we add .bak because BSD sed, used also
# on OS X, requires an argument for -i)
find singular -name '*.h' -exec sed -i -f "$SRC_DIR/fix_includes.sed" {} \;

