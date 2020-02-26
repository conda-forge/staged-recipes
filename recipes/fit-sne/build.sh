#! /bin/sh

export CPPFLAG="$CXXFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

$CXX -std=c++11 -O3  src/sptree.cpp src/tsne.cpp src/nbodyfft.cpp -o fast_tsne \
  $CPPFLAGS $LDFLAGS -pthread -lfftw3 -lm -Wno-address-of-packed-member

mkdir -p $PREFIX/bin && mv fast_tsne $PREFIX/bin
