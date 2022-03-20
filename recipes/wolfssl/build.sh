#!/bin/bash

set -ex

# the autoconf build has many more supported config options so we
# will continue to use it for unix and cmake only for windows for now

autoreconf --install

# TODO refactor configure into another script that can be shared with build and just add
# --enable-nolibrary to the run_test.sh invocation

./configure --prefix="$PREFIX" \
	    --with-libz="$PREFIX" \
	    --enable-distro

deathcat() {
    cat "$@"
    exit 1
}

make  -j "$CPU_COUNT"
# run tests sequentially because some of them
# make use of bwrap to avoid collisions in the port
# space and I doubt that we have it available in CI
# timout the tests after 5 minutes, send sigkill 5 seconds after
# being nice about it.
timeout -k 5 5m make -j1 check || deathcat ./test-suite.log
make install

