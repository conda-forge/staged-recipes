#!/bin/bash

set -e
set -x

mkdir -p $PREFIX/NOTICE

# Create the site-packages dir if it doesn't exist
mkdir -p $SP_DIR
echo "site-packages dir, SP_DIR = $SP_DIR"

rm -v lib/libyaml-cpp*
rm -vr include/yaml-cpp

rm -v lib/libuc[mpst]*
rm -vr lib/ucx

check-glibc bin/* lib/* lib/ucx/* lib/gxf_extensions/*
find python/ -name "*.so*" | xargs -I"{}" check-glibc "{}"

cp -v NOTICE $PREFIX/NOTICE
cp -rv bin $PREFIX/
cp -rv examples $PREFIX/
cp -rv lib $PREFIX/
cp -rv include $PREFIX/
cp -rv python/lib/* $SP_DIR/
