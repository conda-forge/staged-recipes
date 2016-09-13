#!/bin/bash

# gstreamer expects libffi to be in lib64 for some reason.
mkdir $PREFIX/lib64
cp -r $PREFIX/lib/libffi* $PREFIX/lib64

# The datarootdir option places the docs into a temp folder that won't
# be included in the package (it is about 12MB).
./configure --disable-examples --prefix="$PREFIX" --datarootdir=`pwd`/tmpshare
make
# Some tests fail because not all plugins are built and it seems
# tests expect all plugins
# See this link for an explanation:
# https://bugzilla.gnome.org/show_bug.cgi?id=752778#c17
# make check || { cat tests/check/test-suite.log; exit 1;}
make install

# Remove the created lib64 directory
rm -rf $PREFIX/lib64
