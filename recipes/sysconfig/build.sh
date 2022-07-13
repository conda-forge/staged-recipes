#!/bin/bash
set -ex

# Install SysConfig: System configuration tool
chmod +x sysconfig-1.13.0_2553-setup.run
./sysconfig-1.13.0_2553-setup.run --mode unattended --prefix $SRC_DIR/tisysconfig

# Copy dist directory
mkdir -p $PREFIX/lib/tisysconfig
cp -r $SRC_DIR/tisysconfig/dist/ $PREFIX/lib/tisysconfig

# Copy tisysconfig script
mkdir -p $PREFIX/bin
chmod +x ${RECIPE_DIR}/tisysconfig.sh
cp ${RECIPE_DIR}/tisysconfig.sh $PREFIX/bin
