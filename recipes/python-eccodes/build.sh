#!/usr/bin/env bash

if [[ $(uname) == Darwin ]]; then
  export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
elif [[ $(uname) == Linux ]]; then
  export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
fi

export PYTHON="$PYTHON"
export PYTHON_LDFLAGS="$PREFIX/lib"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"
export CFLAGS="$CFLAGS -fPIC -I$PREFIX/include"

src_dir="$(pwd)"
mkdir ../build
cd ../build
cmake $src_dir \
         -DCMAKE_INSTALL_PREFIX=$PREFIX \
         -DENABLE_JPG=1 \
         -DENABLE_NETCDF=1 \
         -DENABLE_PNG=1 \
         -DENABLE_PYTHON=1 \
         -DENABLE_FORTRAN=0

make
make install

if [[ $(uname) == Darwin ]]; then
  ln -s $SP_DIR/gribapi/_gribapi_swig.dylib $SP_DIR/gribapi/_gribapi_swig.so
fi
