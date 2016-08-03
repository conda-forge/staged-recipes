#!/usr/bin/env bash
set -e

if [ "$(uname)" == "Darwin" ]; then
  libext=".dylib"
  export LDFLAGS="-rpath ${PREFIX}/lib ${LDFLAGS}"
  skiprpath="-DCMAKE_SKIP_RPATH=TRUE"

  # toolchain copy
  export CC=clang
  export CXX=clang++
  export MACOSX_VERSION_MIN="10.9"
  export MACOSX_DEPLOYMENT_TARGET="${MACOSX_VERSION_MIN}"
  export CMAKE_OSX_DEPLOYMENT_TARGET="${MACOSX_VERSION_MIN}"
  export CFLAGS="${CFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
  export CXXFLAGS="${CXXFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
  export CXXFLAGS="${CXXFLAGS} -stdlib=libc++"
  export LDFLAGS="${LDFLAGS} -headerpad_max_install_names"
  export LDFLAGS="${LDFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
  export LDFLAGS="${LDFLAGS} -lc++"
  export LINKFLAGS="${LDFLAGS}"
  export CFLAGS="${CFLAGS} -m${ARCH}"
  export CXXFLAGS="${CXXFLAGS} -m${ARCH}"
else
  libext=".so"
  skiprpath=""
fi

export VERBOSE=1
${PYTHON} install.py --prefix="${PREFIX}" \
  --build_type="Release" \
  --coin_root="${PREFIX}" \
  --boost_root="${PREFIX}" \
  --hdf5_root="${PREFIX}" \
  -DCMAKE_OSX_DEPLOYMENT_TARGET="${MACOSX_VERSION_MIN}" \
  -DBLAS_LIBRARIES="${PREFIX}/lib/libopenblas${libext}" \
  -DLAPACK_LIBRARIES="${PREFIX}/lib/liblapack${libext}" \
  ${skiprpath} \
  --clean
