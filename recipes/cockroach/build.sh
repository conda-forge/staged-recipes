#!/usr/bin/env bash
set -euf

# Upstream resets the PATH internally in their Makefile.
# It does not work for us.
bindir=$(pwd)/src/github.com/cockroachdb/cockroachdb/bin
mkdir -p $bindir
export PATH=${bindir}:${PATH}

#
# We only install the OSS version of cockroach. 
# The CCL version is not free.
make install-oss prefix=$PREFIX \
	EXTRA_XCMAKE_FLAGS="-DCMAKE_PREFIX_PATH=$PREFIX"
