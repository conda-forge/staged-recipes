#!/usr/bin/env bash

set -xe

make -j"${CPU_COUNT}"

mkdir -p ${PREFIX}/lib
install -m 644 build/lib/libolbcore.a ${PREFIX}/lib/
