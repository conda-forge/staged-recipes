#!/bin/bash

set -xe

wolfssl-config --help

pkg-config --print-provides "$PKG_NAME"
pkg-config --exact-version="$PKG_VERSION" "$PKG_NAME"


# compile&run the examples and tests, using the installed library
# assumes test.source_files has '*' in it and we have the contents of the build dir
make distclean

autoreconf --install
./configure --prefix="$PREFIX" \
            --enable-jobserver="$CPU_COUNT" \
	    --with-libz="$PREFIX" \
	    --enable-distro \
	    --enable-nolibrary

# ensure that enable-nolibrary was used because configure doesn't
# exit non-zero if it ignores an unknown option
grep 'WARNING: unrecognized options' config.log && exit 1

deathcat() {
    cat "$@"
    exit 1
}

make check || deathcat ./test-suite.log
