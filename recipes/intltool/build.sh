#! /bin/bash

if [[ $(uname) == Darwin ]]; then
  export CC=clang
  export CXX=clang++
  export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
  export LDFLAGS="$LDFLAGS -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib -headerpad_max_install_names"
  export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
  export MACOSX_DEPLOYMENT_TARGET="10.9"
  export CXXFLAGS="-stdlib=libc++ $CXXFLAGS"
elif [ "$(uname)" == "Linux" ] ; then
  export CPPFLAGS="-I${PREFIX}/include $CPPFLAGS"
  export LDFLAGS="-L${PREFIX}/lib $LDFLAGS"
fi

# Fix shebangs
for f in tests/selftest.pl.in; do
  sed -i.bak -e 's|^#!@PERL@ -w|#!/usr/bin/env perl|' "$f"
   rm -f "$f.bak"
 done

./configure --prefix=$PREFIX PERL='/usr/bin/env perl'

make -j$CPU_COUNT
make check
make install -j$CPU_COUNT


cd $PREFIX
find . -type f -name "*.la" -exec rm -rf '{}' \; -print
