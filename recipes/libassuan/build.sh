#!/usr/bin/env bash

set -exuo pipefail

autoreconf -if
./configure --prefix=$PREFIX

make
make install

if [[ $CONDA_BUILD_CROSS_COMPILATION != 1 && $target_platform != osx-arm64 ]]; then
	make -v -v -v check
fi
