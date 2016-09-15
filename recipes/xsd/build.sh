#!/bin/bash

export LDFLAGS="$LDFLAGS $(pkg-config --libs xerces-c)"
export CPPFLAGS="$CPPFLAGS $(pkg-config --cflags xerces-c)"

make

# Tests on osx fail because of floating point issues. See
# http://www.codesynthesis.com/pipermail/xsd-users/2015-February/004532.html
# We test the binary in `run_tests.py`
if [[ `uname` != 'Darwin' ]]; then
	make test
fi

make install_prefix="$PREFIX" install

mkdir -p "$PREFIX"/lib/pkgconfig
cp "$RECIPE_DIR"/xsd.pc "$PREFIX"/lib/pkgconfig
