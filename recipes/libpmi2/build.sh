#!/bin/bash
set -ex

unset FFLAGS F77 F90 F95

export CC=$(basename "$CC")
export CXX=$(basename "$CXX")
export FC=$(basename "$FC")

./configure --prefix="$PREFIX" \
	    --disable-dependency-tracking \
	    --without-pmix \
	    --with-munge="$PREFIX" 

cd contribs/pmi2

make -j"${CPU_COUNT}"

make install
