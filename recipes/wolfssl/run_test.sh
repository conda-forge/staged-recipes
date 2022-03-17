#!/bin/bash

set -xe

wolfssl-config --help

pkg-config --print-provides "$PKG_NAME"
pkg-config --exact-version="$PKG_VERSION" "$PKG_NAME"


# compile&run the examples and tests, using the installed library
# assumes test.source_files has '*' in it and we have the contents of the build dir
make distclean

# hack configure.ac to expose ENABLE_NO_LIBRARY to cmdline
for p in "$RECIPE_DIR"/test-patches/*; do
    patch -p1 <"$p"
done


autoreconf --install
./configure --prefix="$PREFIX" \
            --enable-jobserver="$CPU_COUNT" \
	    --with-libz="$PREFIX" \
	    --enable-distro \
	    --enable-nolibrary

deathcat() {
    cat "$@"
    exit 1
}

make check || deathcat ./test-suite.log
