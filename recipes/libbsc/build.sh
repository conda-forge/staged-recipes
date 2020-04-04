#!/bin/bash

mkdir -p $PREFIX/bin
make CC=$CXX
cp bsc $PREFIX/bin/
