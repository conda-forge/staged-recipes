#!/usr/bin/env bash
set -e

export CFLAGS="-O3"
export CXXFLAGS="-O3"
export LIBRARY_PATH="${PREFIX}/lib"
export INCLUDE_PATH="${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib"
if [ "$(uname)" == "Darwin" ]; then
  # for Mac OSX
  export CC=clang
  export CXX=clang++
  export MACOSX_VERSION_MIN="10.7"
  export CXXFLAGS="${CXXFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
  export CXXFLAGS="${CXXFLAGS} -stdlib=libc++ -std=c++11"
  export LDFLAGS="${LDFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
  export LDFLAGS="${LDFLAGS} -stdlib=libc++ -std=c++11"
  #export LDFLAGS="${LDFLAGS} -L/${PREFIX}/lib"
  export LINKFLAGS="${LDFLAGS}"
fi

# configure, make, install, check
sed -e '/^libdocdir =/ s/$(book_name)/glibmm-'"${PKG_VERSION}"'/' \
    docs/Makefile.in > docs/Makefile.in.new
mv docs/Makefile.in.new docs/Makefile.in
./configure --prefix="${PREFIX}" --exec-prefix="${PREFIX}" \
  || { cat config.log; exit 1; }
make
make install
