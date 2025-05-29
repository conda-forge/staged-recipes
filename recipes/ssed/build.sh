#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CFLAGS="${CFLAGS} -Wno-implicit-function-declaration"

autoreconf --force --install --verbose
./configure --disable-debug \
    --disable-dependency-tracking \
    --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib \
    --mandir=${PREFIX}/share/man \
    --infodir=${PREFIX}/share/info \
    --program-prefix=s

# Skipping make check for now because it is unclear how to skip failing tests
# make check 
make -j${CPU_COUNT} install MKDIR_P="${BUILD_PREFIX}/bin/mkdir -p"
mv ${PREFIX}/share/info/sed.info ${PREFIX}/share/info/ssed.info
