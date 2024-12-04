#!/bin/bash

#tar -xvf autodocksuite-4.2.6-x86_64Linux2.tar
shopt -s expand_aliases

alias csh='tcsh'

mkdir -p $PREFIX/bin


autoreconf -i

mkdir Linux

cd Linux
../configure
make

cp autogrid4 $PREFIX/bin
