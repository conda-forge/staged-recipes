#!/usr/bin/env bash
set -euf

# Upstream resets the PATH internally in their Makefile.
# It does not work for us.
cockroach=$(pwd)/src/github.com/cockroachdb/cockroach
mkdir -p ${cockroach}/bin
export PATH=${cockroach}/bin:${PATH}

# We only install the OSS version of cockroach.
# The CCL version is not free.
make -j1 -C ${cockroach} install-oss prefix=$PREFIX \
	EXTRA_XCMAKE_FLAGS="-DCMAKE_PREFIX_PATH=$PREFIX"
