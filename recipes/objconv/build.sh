#!/bin/bash

mkdir -p $PREFIX/bin
$CXX $CXXFLAGS $CPPFLAGS -o $PREFIX/bin/objconv src/*.cpp $LDFLAGS
chmod +x $PREFIX/bin/objconv
ln -sf $PREFIX/bin/objconv $PREFIX/bin/$HOST-objconv
