#!/usr/bin/env bash
set -e

UNAME="$(uname)"
export CFLAGS="-O3"
export CXXFLAGS="-O3"
if [ "${UNAME}" == "Darwin" ]; then
  # for Mac OSX
  #export CC=clang
  #export CXX=clang++
  export CC=gcc
  export CXX=g++
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

    for OPENBLAS_LIB in $( find "${PREFIX}/lib" -name "libopenblas*.dylib" ); do
        install_name_tool -change \
                @rpath/./libgfortran.3.dylib \
                "${PREFIX}/lib/libgfortran.3.dylib" \
                "${OPENBLAS_LIB}"
        install_name_tool -change \
                @rpath/./libquadmath.0.dylib \
                "${PREFIX}/lib/libquadmath.0.dylib" \
                "${OPENBLAS_LIB}"
        install_name_tool -change \
                @rpath/./libgcc_s.1.dylib \
                "${PREFIX}/lib/libgcc_s.1.dylib" \
                "${OPENBLAS_LIB}"
    done
else
  # for Linux
  export CC=
  export CXX=
  WITH_BLAS_LIB="-L${PREFIX}/lib -lopenblas"
  WITH_LAPACK_LIB="-L${PREFIX}/lib -lopenblas"
fi
CC="${CC}" CXX="${CXX}" ./configure --prefix="${PREFIX}" --exec-prefix="${PREFIX}" \
  --with-blas-lib="${WITH_BLAS_LIB}" \
  --with-lapack-lib="${WITH_LAPACK_LIB}" \
  || { cat config.log; exit 1; }
make
make test
make install
