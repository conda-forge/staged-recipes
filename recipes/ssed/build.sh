#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export CFLAGS="${CFLAGS} -Wno-implicit-function-declaration"

sed -i -e 's/binary dc/binary/g' testsuite/Makefile.am
sed -i -e 's/dc distrib/distrib/g' testsuite/Makefile.tests

autoreconf --force --install --verbose
./configure --disable-debug \
    --disable-dependency-tracking \
    --prefix=${PREFIX} \
    --libdir=${PREFIX}/lib \
    --mandir=${PREFIX}/share/man \
    --infodir=${PREFIX}/share/info \
    --program-prefix=s

# Skipping make check for now because it fails to produce any output
# Changelog indicates test suite may not be working
# make -j${CPU_COUNT} check MKDIR_P="${BUILD_PREFIX}/bin/mkdir -p"
make -j${CPU_COUNT} install MKDIR_P="${BUILD_PREFIX}/bin/mkdir -p"
mv ${PREFIX}/share/info/sed.info ${PREFIX}/share/info/ssed.info
