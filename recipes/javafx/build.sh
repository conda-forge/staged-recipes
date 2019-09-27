#!/bin/bash

# stop on error
set -eu -o pipefail

# build javafx from source
export PKG_CONFIG_PATH="${BUILD_PREFIX}/lib/pkgconfig/:${PKG_CONFIG_PATH}"
if [ -z "${OSX_ARCH}" ]; then
  ln -s "${GCC}" "${BUILD_PREFIX}/bin/gcc"
  ln -s "${GXX}" "${BUILD_PREFIX}/bin/g++"
else # for macOS
  ln -s "${CXX}" "${BUILD_PREFIX}/bin/gcc"
  ln -s "${CXX}" "${BUILD_PREFIX}/bin/g++"
fi

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
