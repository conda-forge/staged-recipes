#!/usr/bin/env bash
set -e

if [ "$(uname)" == "Darwin" ]; then
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
  # other
  libext=".dylib"
  export LDFLAGS="-rpath ${PREFIX}/lib ${LDFLAGS}"
  export LINKFLAGS="${LDFLAGS}"
  skiprpath="-DCMAKE_SKIP_RPATH=TRUE"
else
  libext=".so"
  skiprpath=""
fi

# Install Cycamore
export VERBOSE=1
${PYTHON} install.py --prefix="${PREFIX}" \
  --build_type="Release" \
  --dont-allow-milps \
  --deps-root="${PREFIX}" \
  -DCMAKE_OSX_DEPLOYMENT_TARGET="${MACOSX_VERSION_MIN}" \
  ${skiprpath} \
  --clean -j "${CPU_COUNT}"
