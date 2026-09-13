#!/bin/bash
set -ex

# The redistributable archive uses lib64 on some arches; normalize to lib.
[[ -d lib64 ]] && mv lib64 lib

# Validate the glibc ABI of every shared object in the archive.
find . -name "*.so*" -print0 | xargs -0 -r -n1 check-glibc

mkdir -p "$PREFIX/include"
cp -vrp include/* "$PREFIX/include/"

# Native libs
# Python packages are installed by install_cutlass_dsl.sh on the python output.
mkdir -p "$PREFIX/lib"
cp -vrpd lib/* "$PREFIX/lib/"