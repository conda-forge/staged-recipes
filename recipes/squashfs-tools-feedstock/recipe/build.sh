#!/usr/bin/env bash

# We would enable this but, from lzma_wrapper.c:
#
# * Support for LZMA1 compression using LZMA SDK (4.65 used in
# * development, other versions may work) http://www.7-zip.org/sdk.html
#
#      LZMA_SUPPORT=1 LZMA_DIR=${PREFIX}  \

pushd squashfs-tools
  make -j${CPU_COUNT}  \
      GZIP_SUPPORT=1  \
      LZ4_SUPPORT=1  \
      LZO_SUPPORT=1  \
      XZ_SUPPORT=1  \
      ZSTD_SUPPORT=1
  cp {mk,un}squashfs ${PREFIX}/bin/
popd
