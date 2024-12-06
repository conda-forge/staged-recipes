#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

# Patch build.gradle to add dependency-license-report plugin
sed -i "s/id 'base'/id 'base'\nid 'com.github.jk1.dependency-license-report' version 'latest.release'/" build.gradle

# Build from source with gradle and download third-party licenses
export JAVA_OPTS="-XX:ReservedCodeCacheSize=64m"
./gradlew dev
./gradlew generateLicenseReport

# Copy all files from build snapshot to ${PREFIX}/libexec/solr
# and symlink wrapper scripts to ${PREFIX}/bin
mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/libexec/apache-solr
cp -r ${SRC_DIR}/solr/packaging/build/solr-${PKG_VERSION}-SNAPSHOT/* ${PREFIX}/libexec/apache-solr
ln -sf ${PREFIX}/libexec/apache-solr/bin/solr ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/apache-solr/bin/solr.cmd ${PREFIX}/bin
