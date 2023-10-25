#!/bin/sh -ex
make
mkdir -p "${PREFIX}/bin"
make install "prefix=${PREFIX}"
