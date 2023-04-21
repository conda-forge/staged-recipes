#!/bin/bash
SEMIMAP_INCLUDE=$PREFIX/include/semimap
SEMIMAP_TEST=$PREFIX/test

mkdir -p $SEMIMAP_INCLUDE
mkdir -p $SEMIMAP_TEST

# Copy the header-only library file to the include directory
cp semimap.h $SEMIMAP_INCLUDE

cp test.cpp $SEMIMAP_TEST
