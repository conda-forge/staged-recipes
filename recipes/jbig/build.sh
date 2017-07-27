#!/bin/bash

# Patch (support old gcc)
sed -i.bak 's/-Wno-unused-result//g' Makefile

# Build
make lib

# Test
make test

# Install
mkdir -p "${PREFIX}/lib" "${PREFIX}/include"
cp libjbig/*.a "${PREFIX}/lib"
cp libjbig/*.h "${PREFIX}/include"
