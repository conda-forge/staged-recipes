#!/bin/bash


# create directories if they don't exist
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib
mkdir -p $PREFIX/include

# create bin folder and make from Makefile
mkdir -p bin
make

# copy executable to dest
cp ./bin/qpad.e $PREFIX/bin/
