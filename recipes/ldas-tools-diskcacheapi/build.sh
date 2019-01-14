#!/bin/bash

./configure \
  --prefix=${PREFIX} \
  --disable-warnings-as-errors \
  --with-optimization=high \
  --without-doxygen \
  --without-dot

# build
make -j ${CPU_COUNT}

# install
make -j ${CPU_COUNT} install
