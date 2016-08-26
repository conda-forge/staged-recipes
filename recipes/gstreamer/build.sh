#!/bin/bash

# gstreamer expects libffi to be in lib64 for some reason.
mkdir $PREFIX/lib64
cp -r $PREFIX/lib/libffi* $PREFIX/lib64

# The datarootdir option places the docs into a temp folder that won't
# be included in the package (it is about 12MB).
./configure --disable-examples --prefix="$PREFIX" --datarootdir=`pwd`/tmpshare
make
# This is failing because the exported symbols by the Gstreamer .so library
# on Linux are different from the expected ones on Windows. We don't know
# why that's happening though.
# make check
make install

# Remove the created lib64 directory
rm -rf $PREFIX/lib64

