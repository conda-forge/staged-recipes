#!/bin/bash

# https://stackoverflow.com/questions/72635283/how-to-create-conda-package-for-a-tool

#tar -xvf autodocksuite-4.2.6-x86_64Linux2.tar

mkdir -p $PREFIX/bin

cp autodock4 $PREFIX/bin/
cp autogrid4 $PREFIX/bin/
