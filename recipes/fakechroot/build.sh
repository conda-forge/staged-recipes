#!/usr/bin/env bash

set -e -o pipefail

./autogen.sh
./configure --prefix $PREFIX

make -j $CPU_COUNT
set +e
make check
cat test/test-suite.log
set -e

make install

