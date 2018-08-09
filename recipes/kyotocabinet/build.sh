#!/bin/bash

set -e

# Set compiler flags

CFLAGS="$CFLAGS -std=c++0x"
LDFLAGS="$LDFLAGS -std=c++0x"
CPPFLAGS="$CPPFLAGS -std=c++0x"
CXXFLAGS="$CXXFLAGS -std=c++0x"

# Run the configure script

./configure --prefix=$PREFIX

# Compile, check and install

make
make check &> make_check.log || { cat make_check.log; exit 1; }
make install
