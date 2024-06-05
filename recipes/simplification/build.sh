#!/bin/bash
set -ex

git_latest_version() {
	curl --silent "https://api.github.com/repos/$1/releases/latest" |
		grep '"tag_name":' |
		sed -E 's/.*"([^"]+)".*/\1/'
}

tag=$(git_latest_version urschrei/rdp)

if [ ${target_platform} == "linux-64" ]; then
	filename="rdp-${tag}-x86_64-unknown-linux-gnu.tar.gz"
elif [ ${target_platform} == "linux-aarch64" ]; then
	filename="rdp-${tag}-aarch64-unknown-linux-gnu.tar.gz"
elif [ ${target_platform} == "osx-arm64" ]; then
	filename="rdp-${tag}-aarch64-apple-darwin.tar.gz"
elif [ ${target_platform} == "osx-64" ]; then
	filename="rdp-${tag}-x86_64-apple-darwin.tar.gz"
fi

url="https://github.com/urschrei/rdp/releases/download/${tag}/${filename}"
curl -L $url -o $filename
tar -xvf $filename -C src/simplification

$PYTHON -m pip install . -vv --no-deps --no-build-isolation
