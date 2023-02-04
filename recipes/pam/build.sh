#!/bin/bash
set -ex

./autogen.sh

args=(
  --prefix="$PREFIX"
  --disable-doc
  --disable-debug
  --disable-prelude
  --enable-isadir="$PREFIX/lib/security"
  --disable-econf
  --disable-openssl # check for pam_timestamp with openssl is broken
  --disable-regenerate-docu
)

./configure "${args[@]}"

make -j${CPU_COUNT}

make install
