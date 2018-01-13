#!/bin/bash

# Build libf2c.a library

mkdir libf2c
cd libf2c
mv ../libf2c.zip .
unzip libf2c.zip

# Using the makefile provided with the package
# but adding the -fPIC option to the CFLAGS
sed 's/CFLAGS = -O/CFLAGS = -O -fPIC/g' makefile.u > Makefile

make hadd
make all

# Make sure ${PREFIX}/lib exists, it might not since
# this package does not depend on anything
mkdir -p ${PREFIX}/lib

make install LIBDIR=${PREFIX}/lib 

# Some programs need f2c.h to be in ${PREFIX/include, some in ${PREFIX}/include/f2c
# "make install" above does not install it, so we need to do it manually
mkdir -p ${PREFIX}/include
cp f2c.h ${PREFIX}/include
mkdir ${PREFIX}/include/f2c
cp f2c.h ${PREFIX}/include/f2c

# Now build the f2c executable
cd ../src

cp makefile.u Makefile

make f2c

# Install the binary
cp f2c ${PREFIX}/bin/

# Now copy a small "Hello world" program into the share folder so
# we can test the installation later on
mkdir -p ${PREFIX}/share/f2c

cp ${RECIPE_DIR}/test_main.f ${PREFIX}/share/f2c
