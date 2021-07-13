#!/bin/bash
cd src
make
make enum.x
make polya.x

cp enum.x $PREFIX/bin
cp polya.x $PREFIX/bin
