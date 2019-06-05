#!/bin/bash
set -ex

cd src
./configure --prefix="${PREFIX}" \
    --includedir="${PREFIX}/include"
make install
make check
