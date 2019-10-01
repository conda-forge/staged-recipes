#!/bin/bash

# dectect macOS
IS_MAX_OS=0
if [ ! -z "${OSX_ARCH}" ]; then
  IS_MAX_OS=1
fi

# stop on error
set -eu -o pipefail

# configure build environment
#export PKG_CONFIG_PATH="${BUILD_PREFIX}/lib/pkgconfig/:${PKG_CONFIG_PATH}"

# build javafx from source
chmod u+x gradlew
./gradlew
./gradlew test -x :web:test

# create output folder name
VERSION="${PKG_NAME}-${PKG_VERSION}"
OUT="${PREFIX}/lib/${VERSION}"

# move the files to /lib/${VERSION}
mkdir -p "${OUT}"
mv build/sdk/legal/ "${OUT}/."
mv build/sdk/lib/ "${OUT}/."
