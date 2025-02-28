#!/bin/bash
set -ex -o pipefail

export JAVA_HOME=$PREFIX/lib/jvm

# Build OpenSearch distribution (https://github.com/opensearch-project/OpenSearch/blob/main/DEVELOPER_GUIDE.md#gradle-build)
./gradlew localDistro


mkdir -p "$PREFIX/bin"
mkdir -p "$PREFIX/lib"
mkdir -p "$PREFIX/share/opensearch"

# Find the exact built files directory
OPENSEARCH_DIR=$(find build/distribution/local -type d -name "opensearch-*" | head -n 1)
cp -r "$OPENSEARCH_DIR"/* "$PREFIX/share/opensearch/"

for exe in "$PREFIX/share/opensearch/bin"/*; do
    [ -x "$exe" ] && ln -sf "$exe" "$PREFIX/bin/$(basename "$exe")"
done

