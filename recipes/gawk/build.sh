#!/bin/bash
./configure \
  --prefix="${PREFIX}" \
  --with-readline="${PREFIX}" \
  --with-mpfr="${PREFIX}"

make -j${NUM_CPUS}

make check

make install
