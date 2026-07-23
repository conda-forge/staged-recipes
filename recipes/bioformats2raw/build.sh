#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail -o xtrace

# Dependencies and the pinned license-report plugin are intentionally resolved
# over the network. Gradle itself is supplied by conda-forge.
export GRADLE_USER_HOME="${SRC_DIR}/.gradle-conda"
install -d "${BUILD_PREFIX}/bioformats2raw-tmp"
export JAVA_TOOL_OPTIONS="-Djava.io.tmpdir=${BUILD_PREFIX}/bioformats2raw-tmp"
gradle --no-daemon --stacktrace clean test installDist generateLicenseReport

install -d "${PREFIX}/share/bioformats2raw" "${PREFIX}/bin"
cp -R build/install/bioformats2raw/. "${PREFIX}/share/bioformats2raw/"
ln -s ../share/bioformats2raw/bin/bioformats2raw "${PREFIX}/bin/bioformats2raw"
