#!/bin/bash
set -ex

./configure --prefix="$PREFIX" \
	    --disable-dependency-tracking \
	    --without-pmix \
	    --with-munge="$PREFIX"

cd contribs/pmi2

make -j"${CPU_COUNT}"

make install
