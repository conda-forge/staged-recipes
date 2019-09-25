#!/bin/bash

# stop on error
set -eu -o pipefail

# todo: replace with gradle in conda-forge channel
conda install --yes -c hcc gradle

# build javafx from source
export PKG_CONFIG_PATH=${PKG_CONFIG_PATH}:${PREFIX}/lib64/pkgconfig
echo $PKG_CONFIG_PATH
ls -la ${PREFIX}/lib64/pkgconfig
gradle
gradle checks

# create output folder name
VERSION="${PKG_NAME}-${PKG_VERSION%\.*}"
OUT="${PREFIX}/lib/${VERSION}"

# copy the files to /lib/${VERSION}
mkdir -p "${OUT}"
cp -R build/sdk/legal/ "${OUT}/."
cp -R build/sdk/lib/* "${OUT}/."
