#!/usr/bin/env bash

set -e

if [[ "$c_compiler" == "gcc" ]]; then
  export PATH="${PATH}:${BUILD_PREFIX}/${HOST}/sysroot/usr/lib"
fi

export PYTHON=
export LDFLAGS="$LDFLAGS -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"
export CFLAGS="$CFLAGS -fPIC -I$PREFIX/include"

mkdir ../build && cd ../build

if [[ $(uname) == Linux ]]; then
    # rpcgen searches for cpp in /lib/cpp and /cpp.
    # It's possible to pass a path to rpcgen using `-Y` but this is a directory path - rpcgen
    # expects a `cpp` binary inside that directory.
    # $CPP on conda-forge is a path to a binary of form `x86_64-conda_cos6-linux-gnu-cpp` which
    # causes rpcgen to fail to find it.
    # Therefore we create a symlink which rpcgen can use.
    ln -s "$CPP" ./cpp
    export CPP="$PWD/cpp"
    RPCGEN_USE_CPP_ENV=1
else
    RPCGEN_USE_CPP_ENV=0
fi

cmake -D CMAKE_INSTALL_PREFIX=$PREFIX \
      -D ENABLE_DOCS=0 \
      -D RPCGEN_USE_CPP_ENV=$RPCGEN_USE_CPP_ENV \
      $SRC_DIR

make -j $CPU_COUNT

ctest --output-on-failure -j $CPU_COUNT -I $RECIPE_DIR/test_list.txt
make install
