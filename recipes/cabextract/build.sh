#!/bin/bash
./configure
make
mkdir -p $PREFIX/bin
cp cabextract $PREFIX/bin/cabextract
