#!/usr/bin/env bash

set -e -o pipefail

./autogen.sh
./configure --prefix $PREFIX

make -j $CPU_COUNT
make install
