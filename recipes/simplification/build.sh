#!/bin/bash
set -ex

if [ ${target_platform} == "linux-64" ]; then
	FILENAME="rdp-${RDPTAG}-x86_64-unknown-linux-gnu.tar.gz"
elif [ ${target_platform} == "linux-aarch64" ]; then
	FILENAME="rdp-${RDPTAG}-aarch64-unknown-linux-gnu.tar.gz"
elif [ ${target_platform} == "osx-arm64" ]; then
	FILENAME="rdp-${RDPTAG}-aarch64-apple-darwin.tar.gz"
elif [ ${target_platform} == "osx-64" ]; then
	FILENAME="rdp-${RDPTAG}-x86_64-apple-darwin.tar.gz"
fi

URL="https://github.com/urschrei/rdp/releases/download/${RDPTAG}/${FILENAME}"
curl -L $URL -o $FILENAME
tar -xvf $FILENAME -C src/simplification

$PYTHON -m pip install . -vv --no-deps --no-build-isolation
