#!/bin/bash

CXX=$CXX

mkdir -p "$PREFIX/bin"
make -B
cp ri36 "$PREFIX/bin"
chmod +x "$PREFIX/bin/ri36"
