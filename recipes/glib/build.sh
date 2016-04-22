#!/usr/bin/env bash
export CFLAGS="-O3"
export CXXFLAGS="-O3"
export LIBRARY_PATH="${PREFIX}/lib"
export INCLUDE_PATH="${PREFIX}/include"
export C_INCLUDE_PATH="${PREFIX}/include"
export LDFLAGS="-L/${PREFIX}/lib"
export PKG_CONFIG="${PREFIX}/bin/pkg-config"
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig"
#if [ "$(uname)" == "Darwin" ]; then
   # for Mac OSX
#  export CC=clang
#  export CXX=clang++
#  export MACOSX_VERSION_MIN="10.7"
#  export CFLAGS="${CFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
#  export CXXFLAGS="${CXXFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
#  #export CXXFLAGS="${CXXFLAGS} -stdlib=libc++ -std=c++11"
#  export LDFLAGS="${LDFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
#  #export LDFLAGS="${LDFLAGS} -stdlib=libc++ -std=c++11"
#  export CFLAGS="${CFLAGS} -m64"
#  export CXXFLAGS="${CXXFLAGS} -m64"
#  export LDFLAGS="${LDFLAGS} -m64"
#  export LINKFLAGS="${LDFLAGS}"
#  #export LD_LIBRARY_PATH="${PREFIX}/lib:${LD_LIBRARY_PATH}"
#  export DYLD_LIBRARY_PATH="${PREFIX}/lib:${DYLD_LIBRARY_PATH}"
#  #export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib:${DYLD_FALLBACK_LIBRARY_PATH}"
#else
#  # for linux
#  export CC=
#  export CXX=
#fi

#CC=${CC} CXX=${CXX} ./configure --prefix="${PREFIX}" \
./configure --prefix="${PREFIX}" \
  --with-python="${PYTHON}" --with-libiconv=gnu\
  CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" \
  INCLUDE_PATH="${INCLUDE_PATH}" C_INCLUDE_PATH="${C_INCLUDE_PATH}" \
  PKG_CONFIG="${PKG_CONFIG}" PKG_CONFIG_PATH="${PKG_CONFIG_PATH}" || \
  cat config.log
make
make install
