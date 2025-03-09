#!/bin/bash
set -ex -o pipefail

export JAVA_OPTS="-XX:ReservedCodeCacheSize=64m"

sed -i "s/id 'lifecycle-base'/id 'lifecycle-base'\nid 'com.github.jk1.dependency-license-report' version '2.9'/" build.gradle

# Build OpenSearch distribution (https://github.com/opensearch-project/OpenSearch/blob/main/DEVELOPER_GUIDE.md#gradle-build)
./gradlew localDistro

# Download dependency licenses
./gradlew generateLicenseReport

mkdir -p "$PREFIX/bin"
mkdir -p "$PREFIX/lib"
mkdir -p "$PREFIX/libexec"

# Find the exact built files directory
OPENSEARCH_DIR=$(find build/distribution/local -type d -name "opensearch-*" | head -n 1)
cp -r "$OPENSEARCH_DIR"/* "$PREFIX/libexec"

for exe in "$PREFIX/libexec/bin"/*; do
    [ -x "$exe" ] && ln -sf "$exe" "$PREFIX/bin/$(basename "$exe")"
done

