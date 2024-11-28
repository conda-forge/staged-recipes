#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Build with maven
mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/bin

./gradlew clean dist

cp -r ${SRC_DIR}/dist/kotlinc/bin ${PREFIX}/libexec/${PKG_NAME}
cp -r ${SRC_DIR}/dist/kotlinc/lib ${PREFIX}/libexec/${PKG_NAME}

ln -sf ${PREFIX}/libexec/${PKG_NAME}/bin/* ${PREFIX}/bin
