#!/usr/bin/env bash

make tetgen tetlib
mkdir -p "$PREFIX/bin"
mkdir -p "$PREFIX/lib"
mkdir -p "$PREFIX/include"
cp tetgen "$PREFIX/bin"
cp libtet.a "$PREFIX/lib"
cp tetgen.h "$PREFIX/include"
