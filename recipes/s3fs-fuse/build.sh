#!/usr/bin/env bash
./autogen.sh

export CXXFLAGS="-I${CONDA_PREFIX}/include -I${CONDA_PREFIX}/include/libxml2"
export LDFLAGS="-L${CONDA_PREFIX}/lib"

./configure \
  --prefix=${CONDA_PREFIX} \
  --sbindir=${PREFIX}/bin \
  --with-openssl

make

make install
