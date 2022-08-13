#!/bin/bash

set -ex

# doesn't use autoconf and needs flags passed on make cmdline
#

CPPFLAGS+=" -Dunix"
if [[ $(uname) == Darwin ]]; then
    CPPFLAGS+=" -DBSD"
fi

mkargs=(
  -j"$CPU_COUNT" 
  CXX="$CXX" 
  CPPFLAGS="$CPPFLAGS"
  CXXFLAGS="$CXXFLAGS -O3 -fopenmp" 
  LDFLAGS="$LDFLAGS -fopenmp"
  PREFIX="$PREFIX" 
  MANDIR="${PREFIX}/man"
)

make "${mkargs[@]}" 
make "${mkargs[@]}" check
make "${mkargs[@]}" install
