#!/bin/bash

set -e

check-glibc lib/libcufftMp.so.*

mkdir -p $PREFIX/lib/

cp -rv include $PREFIX/
cp -rv lib $PREFIX/
