#!/bin/bash

set -ex

if [[ ${target_platform} == osx-* ]]; then
  EXTRA_CONF="--disable-avx512 --disable-runtime-cpu-detect"
else
  EXTRA_CONF="--enable-runtime-cpu-detect"
fi

./configure --prefix=${PREFIX}           \
            ${HOST_BUILD}                \
            --as=yasm                    \
            --enable-shared              \
            --disable-install-docs       \
            --disable-install-srcs       \
            --enable-vp8                 \
            --enable-postproc            \
            --enable-vp9                 \
            --enable-vp9-highbitdepth    \
            --enable-pic                 \
            ${EXTRA_CONF}                \
            --enable-experimental || exit 1

make -j${CPU_COUNT}
make install
