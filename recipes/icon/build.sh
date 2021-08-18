#!/bin/env bash
make Configure name=linux
# point make to the real gcc
export CC=x86_64-conda-linux-gnu-gcc
# Build Icon binaries
make CC=${CC}
# Run a small sample of the test suite
make Samples
# Install it assuming that we made it this far
mkdir -p ${PREFIX}/bin
make Install dest=${PREFIX}/icon
(pushd ${PREFIX}/bin && ln -s ../icon/bin/* .)
sed -e "1,/Note Well/d" ${RECIPE_DIR}/LICENSE.txt > ${PREFIX}/icon/LICENSE.txt
