#!/bin/bash
set -ex

cd src
./configure --prefix="${PREFIX}"
make
make check
make install
