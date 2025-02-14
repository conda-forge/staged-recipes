#!/bin/bash

set -e
set -x

check-glibc bin/* lib/* lib/ucx/* lib/gxf_extensions/*

cp -rv bin $PREFIX
cp -rv examples $PREFIX
cp -rv lib $PREFIX
cp -rv include $PREFIX
cp -rv python $PREFIX

echo $SP_DIR

# Create the site-packages dir if it doesn't exist
mkdir -p $SP_DIR

# Add a .pth file that references extra directory needed by holoscan
echo "$PREFIX/python/lib" > $SP_DIR/holoscan_extra.pth

