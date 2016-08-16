#!/bin/bash

# Get rid of bad `defaults` .la files.
rm -rf $PREFIX/lib/*.la


if [ $(uname) == Darwin ]; then
  export CC=clang
  export CXX=clang++
  export MACOSX_DEPLOYMENT_TARGET="10.9"
  export CXXFLAGS="-stdlib=libc++ $CXXFLAGS"
  export CXXFLAGS="$CXXFLAGS -stdlib=libc++"
  export OPTS=""
elif [[ $(uname) == Linux ]]; then
  export OPTS="--with-gobject"
fi

autoreconf --force --install

# FIXME: Locally it does have the executable bits :-/
bash configure --prefix=$PREFIX \
               --disable-gtk-doc \
               --enable-static \
               $OPTS

make

# =================================================
#    HarfBuzz 1.0.6: test/shaping/test-suite.log
# =================================================
#
# # TOTAL: 14
# # PASS:  13
# # SKIP:  0
# # XFAIL: 0
# # FAIL:  1
# # XPASS: 0
# # ERROR: 0
#
# .. contents:: :depth: 2
#
# FAIL: tests/fuzzed
# ==================
#
# Running tests in ./tests/fuzzed.tests
# Testing fonts/sha1sum/1a6f1687b7a221f9f2c834b0b360d3c8463b6daf.ttf:U+0041
# Testing fonts/sha1sum/5a5daf5eb5a4db77a2baa3ad9c7a6ed6e0655fa8.ttf:U+0041
# Testing fonts/sha1sum/0509e80afb379d16560e9e47bdd7d888bebdebc6.ttf:U+0041
# Testing fonts/sha1sum/641bd9db850193064d17575053ae2bf8ec149ddc.ttf:U+0041
# Testing fonts/sha1sum/375d6ae32a3cbe52fbf81a4e5777e3377675d5a3.ttf:U+0041
# Actual:   [gid0=0+4352]
# Expected: [gid0=0+2048]
# 1 tests failed.
# make check

make install
