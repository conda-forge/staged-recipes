#!/bin/bash

set -ex

# the autoconf build has many more supported config options so we
# will continue to use it for unix and cmake only for windows for now

autoreconf --install

# TODO refactor configure into another script that can be shared with build and just add
# --enable-nolibrary to the run_test.sh invocation

./configure --prefix="$PREFIX" \
            --enable-jobserver="$CPU_COUNT" \
	    --with-libz="$PREFIX" \
	    --enable-distro

make 
make check
make install

