#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

mkdir -p ${PREFIX}/libexec/${PKG_NAME}
mkdir -p ${PREFIX}/bin

# Add dependency-license-report as a plugin for build.gradle.kts
sed -i 's/kotlin("jvm")/kotlin("jvm")\nid("com.github.jk1.dependency-license-report") version "latest.release"/' build.gradle.kts

# Build with gradle
./gradlew :server:build -PjavaVersion=21 -x test
./gradlew generateLicenseReport -PjavaVersion=21 -x test

# Copy outputs and symlink bash and batch wrappers provided by upstream source.
cp -r ${SRC_DIR}/server/build/install/server/lib ${PREFIX}/libexec/${PKG_NAME}
cp -r ${SRC_DIR}/server/build/install/server/bin ${PREFIX}/libexec/${PKG_NAME}
ln -sf ${PREFIX}/libexec/${PKG_NAME}/bin/* ${PREFIX}/bin
