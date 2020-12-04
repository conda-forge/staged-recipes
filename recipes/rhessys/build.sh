#!/bin/bash

if [[ $(uname) == Linux ]]; then
  ln -s "${CC}" "${BUILD_PREFIX}/bin/gcc"
fi

export F_MASTER=$(pwd)
make -C ${F_MASTER} -f makefile