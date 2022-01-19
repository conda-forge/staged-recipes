#!/bin/sh

make BUILD_DYNAMIC_LIB=1 BUILD_STATIC_LIB=0 install

# Remove tools and manuals
rm -rf $PREFIX/bin
rm -rf $PREFIX/sbin
rm -rf $PREFIX/share
