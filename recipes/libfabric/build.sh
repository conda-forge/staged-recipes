#!/bin/bash

set -ex

export CC=$(basename "$CC")

build_with_numa=""
build_with_libnl=""
if [[ "$target_platform" == linux-* ]]; then
  echo "Build with numa and libnl support"
  build_with_numa=" --with-numa=$PREFIX "
  build_with_libnl=" --with-libnl=$PREFIX "
fi

echo "==============================================="
./configure --help
echo "==============================================="

./configure --prefix=$PREFIX \
            $build_with_numa  \
            $build_with_libnl \
            --disable-static \
	    --disable-psm3

make -j"${CPU_COUNT}"

if [[ "$target_platform" == linux-* ]]; then
  make check
fi

make install

