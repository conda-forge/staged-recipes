#!/bin/bash

set -ex

export CC=$(basename "$CC")

build_with_libnl=""
if [[ "$target_platform" == linux-* ]]; then
  echo "Build with libnl support"
  build_with_libnl=" --with-libnl=$PREFIX "
fi

./configure --prefix=$PREFIX \
            $build_with_libnl \
            --disable-static \
	    --disable-psm3 \
	    --disable-opx

make -j"${CPU_COUNT}"

if [[ "$target_platform" == linux-* ]]; then
  make check
fi

make install

