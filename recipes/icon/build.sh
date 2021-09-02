#!/bin/env bash
make Configure name=linux

make CC=${CC}

# Run a small sample of the test suite
make Samples

# Install it assuming that we made it this far
mkdir -p ${PREFIX}/bin
make Install dest=${PREFIX}/icon
(pushd ${PREFIX}/bin && ln -s ../icon/bin/* .)
