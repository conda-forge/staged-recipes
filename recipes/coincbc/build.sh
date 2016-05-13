#!/usr/bin/env bash
set -e

UNAME="$(uname)"
export CFLAGS="-O3"
export CXXFLAGS="-O3"
if [ "${UNAME}" == "Darwin" ]; then
  # for Mac OSX
  export CC=clang
  export CXX=clang++
  export MACOSX_VERSION_MIN="10.7"
  export MACOSX_DEPLOYMENT_TARGET="${MACOSX_VERSION_MIN}"
  export CXXFLAGS="${CXXFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
  #export CXXFLAGS="${CXXFLAGS} -stdlib=libc++"
  export LDFLAGS="${LDFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
  #export LDFLAGS="${LDFLAGS} -stdlib=libc++ -lc++"
  export LINKFLAGS="${LDFLAGS}"

  # Coin options
  export CFLAGS="${CFLAGS} -headerpad_max_install_names -headerpad"
  export CXXFLAGS="${CXXFLAGS} -headerpad_max_install_names -headerpad"
  export LDFLAGS="${LDFLAGS} -headerpad_max_install_names -headerpad"
  WITH_BLAS_LIB="-L${PREFIX}/lib -lopenblas"
  WITH_LAPACK_LIB="-L${PREFIX}/lib -lopenblas"
else
  # for Linux
  WITH_BLAS_LIB="-L${PREFIX}/lib -lopenblas"
  WITH_LAPACK_LIB="-L${PREFIX}/lib -lopenblas"
fi

./configure --prefix="${PREFIX}" --exec-prefix="${PREFIX}" \
  --with-blas-lib="${WITH_BLAS_LIB}" \
  --with-lapack-lib="${WITH_LAPACK_LIB}" \
  || { cat config.log; exit 1; }
make
make test
make install
