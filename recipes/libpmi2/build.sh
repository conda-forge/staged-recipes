#!/bin/bash
set -ex

export CC=$(basename "$CC")

./configure --prefix="$PREFIX" \
	    --disable-dependency-tracking \
	    --without-pmix \
	    --with-munge="$PREFIX" 

cd contribs/pmi2

make -j"${CPU_COUNT}"

make install
