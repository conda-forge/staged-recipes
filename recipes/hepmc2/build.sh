#!/usr/bin/env bash
# Enable bash strict mode
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

cd source

PLATF_CONFIG_OPTS="--enable-static"

perl -p -i -e 's|glibtoolize|libtoolize|g' ./bootstrap

export HEPMC_NODOC=1

./bootstrap
./configure $PLATF_CONFIG_OPTS --prefix=${PREFIX} --with-momentum=GEV --with-length=MM

make -j${CPU_COUNT}

make install

exit 0
