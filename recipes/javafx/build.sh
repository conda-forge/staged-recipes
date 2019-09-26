#!/bin/bash

# stop on error
set -eu -o pipefail

# build javafx from source
export PKG_CONFIG_PATH="${BUILD_PREFIX}/lib/pkgconfig/:${PKG_CONFIG_PATH}"

ln -s $GCC ${BUILD_PREFIX}/bin/gcc
ln -s $GXX ${BUILD_PREFIX}/bin/g++

chmod u+x gradlew
./gradlew
./gradlew test -x :web:test

# create output folder name
VERSION="${PKG_NAME}-${PKG_VERSION%\.*}"
OUT="${PREFIX}/lib/${VERSION}"
echo $OUT
# copy the files to /lib/${VERSION}
mkdir -p "${OUT}"
cp -R build/sdk/legal/ "${OUT}/."
cp -R build/sdk/lib/* "${OUT}/."
ls -la $OUT
ls -la $OUT/*
