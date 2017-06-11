#!/usr/bin/env bash

make
make trilibrary
mkdir -p "${PREFIX}/bin"
cp triangle "${PREFIX}/bin"
mkdir -p "${PREFIX}/lib"
cp libtri.a "${PREFIX}/lib"
mkdir -p "${PREFIX}/include"
cp triangle.h "${PREFIX}/include"
