#!/bin/sh
set -e

./get.ASL

./configure --prefix="${PREFIX}"
make -j "${CPU_COUNT}"
make install
