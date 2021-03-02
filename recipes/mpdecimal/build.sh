#!/bin/bash

./configure --prefix=$PREFIX || exit 1

make || exit 1

if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
  make check || exit 1
fi

make install
