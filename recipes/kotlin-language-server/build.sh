#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Build with maven
mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/bin

sed -i 's/kotlin("jvm")/kotlin("jvm")\nid("com.github.jk1.dependency-license-report") version "latest.release"/' build.gradle.kts

./gradlew :server:build -PjavaVersion=21 -x test

./gradlew generateLicenseReport -PjavaVersion=21 -x test

cp -r ${SRC_DIR}/server/build/install/server/lib ${PREFIX}/libexec/${PKG_NAME}
cp -r ${SRC_DIR}/server/build/install/server/bin ${PREFIX}/libexec/${PKG_NAME}
ln -sf ${PREFIX}/libexec/${PKG_NAME}/bin/* ${PREFIX}/bin
