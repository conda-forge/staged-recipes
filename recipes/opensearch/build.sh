#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export JAVA_OPTS="-XX:ReservedCodeCacheSize=64m"
# https://opensearch.org/docs/1.0/opensearch/install/important-settings/
export OPENSEARCH_JAVA_OPTS="-Xms512m -Xmx512m"
sed -i "s/id 'lifecycle-base'/id 'lifecycle-base'\nid 'com.github.jk1.dependency-license-report' version 'latest.release'/" build.gradle

# Build OpenSearch distribution (https://github.com/opensearch-project/OpenSearch/blob/main/DEVELOPER_GUIDE.md#gradle-build)
./gradlew -Dbuild.noJdk=true localDistro

# Download dependency licenses
./gradlew publishToMavenLocal --warning-mode all

mkdir -p "$PREFIX/bin"
mkdir -p "$PREFIX/libexec/opensearch"
mkdir -p "${PREFIX}/libexec/opensearch/logs"

rm -rf build/distribution/local/opensearch-${PKG_VERSION}-SNAPSHOT/jdk
rm -rf build/distribution/local/opensearch-${PKG_VERSION}-SNAPSHOT/jdk.app

cp -r build/distribution/local/opensearch-${PKG_VERSION}-SNAPSHOT/* ${PREFIX}/libexec/opensearch

ln -sf ${PREFIX}/libexec/opensearch/bin/* ${PREFIX}/bin