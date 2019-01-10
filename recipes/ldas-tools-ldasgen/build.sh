#!/bin/bash

./configure \
  --prefix=${PREFIX} \
  --with-optimization=high \
  --disable-tcl \
  --disable-python \
  --without-doxygen \
  --without-dot \
  --with-boost=${PREFIX}

# build
make -j ${CPU_COUNT}

# test
make -j ${CPU_COUNT} check

# install
make -j ${CPU_COUNT} install
