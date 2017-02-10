#!/bin/bash

export CPPFLAGS="-I$PREFIX/include $CPPFLAGS"
export LDFLAGS="-L$PREFIX/lib $LDFLAGS"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export CFLAGS="-O2 -g $CFLAGS -fPIC -DFAST -DALLTRUE"

chmod 644 *.c

for patch in $RECIPE_DIR/patches/*.patch; do
    [ -r "$patch" ] || continue  # Skip non-existing or non-readable patches
    git apply -p1 <"$patch"
    if [ $? -ne 0 ]; then
        echo >&2 "Error applying '$patch'"
        exit 1
    fi
done

cp "$RECIPE_DIR"/patches/makefile .
 
make
make test

actual=`echo 123 | ./test`
expected=" 12.146304.367025.329675.766243.241881.295855.454217.088483.382315.
 328918.161829.235892.362167.668831.156960.612640.202170.735835.221294.
 047782.591091.570411.651472.186029.519906.261646.730733.907419.814952.
 960000.000000.000000.000000.000000 "

if [ "$actual" != "$expected" ]; then
    exit 1
fi

mkdir -p "$PREFIX"/lib
cp libsymmetrica.a "$PREFIX"/lib/
mkdir -p "$PREFIX"/include/symmetrica
cp *.h "$PREFIX"/include/symmetrica/
