#!/bin/bash

# stop on error
#set -eu -o pipefail

# todo: replace with gradle in conda-forge channel
conda install --yes -c hcc gradle

# build javafx from source
export PKG_CONFIG_PATH="${BUILD_PREFIX}/x86_64-conda_cos6-linux-gnu/sysroot/usr/lib64/pkgconfig/:${PKG_CONFIG_PATH}"
ln -s $GCC ${BUILD_PREFIX}/bin/gcc
ln -s $GXX ${BUILD_PREFIX}/bin/g++

gradle
gradle checks

# create output folder name
VERSION="${PKG_NAME}-${PKG_VERSION%\.*}"
OUT="${PREFIX}/lib/${VERSION}"

# copy the files to /lib/${VERSION}
mkdir -p "${OUT}"
cp -R build/sdk/legal/ "${OUT}/."
cp -R build/sdk/lib/* "${OUT}/."
