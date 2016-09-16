#!/bin/bash

cd WildMagic5

export CFG="ReleaseDynamic"
make -f makefile.wm5

mkdir -p $PREFIX/include/libwildmagic/
cp -r SDK/Include/* $PREFIX/include/libwildmagic
cp -r SDK/Library/$CFC/* $PREFIX/lib

mkdir -p $PREFIX/share/libwildmagic
cp -r Data $PREFIX/share/libwildmagic
