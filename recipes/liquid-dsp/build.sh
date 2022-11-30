#!/usr/bin/env bash

set -ex

# set default include and library dirs for Windows build
if [[ "$target_platform" == win-64 ]]; then
  export CPPFLAGS="$CPPFLAGS -isystem $PREFIX/include"
  export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
fi

configure_args=(
    --prefix=$PREFIX
)

./bootstrap.sh
./configure "${configure_args[@]}"
make -j${CPU_COUNT}
make install

# remove static library
rm $PREFIX/lib/libliquid.a*

if [[ "$target_platform" == win-* ]]; then
  # remove unversioned DLL since Windows doesn't do symlinks
  # (functionally this is replaced by the lib/liquid.lib import lib anyway)
  rm $PREFIX/lib/libliquid.dll
  # put DLLs where they properly belong in bin
  mv $PREFIX/lib/liquid*.dll $PREFIX/bin
fi
