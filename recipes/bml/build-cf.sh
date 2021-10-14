#!/usr/bin/env bash

set -ex

if [[ "${mpi}" != "nompi" ]]; then
  export CXX="$PREFIX/bin/mpicxx"
  export CC="$PREFIX/bin/mpicc"
  export FC="$PREFIX/bin/mpifort"
fi

export INSTALL_DIR=${PREFIX}

./build.sh install
