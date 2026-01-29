#!/bin/bash

set -e
set -x

# Create the site-packages dir if it doesn't exist
mkdir -p $SP_DIR
echo "site-packages dir, SP_DIR = $SP_DIR"

rm -vr include/yaml-cpp

rm -v lib/libuc[mpst]*
rm -vr lib/ucx

check-glibc bin/* lib/* lib/ucx/* lib/gxf_extensions/*
find python/ -name "*.so*" | xargs -I"{}" check-glibc "{}"

cp -rv bin $PREFIX/
cp -rv examples $PREFIX/
cp -rv lib $PREFIX/
cp -rv include $PREFIX/
