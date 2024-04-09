#!/bin/bash

set -exuo pipefail

mkdir -p gopath/bin
export GOPATH=$(pwd)/gopath

export PULUMI_VERSION=${PKG_VERSION}
export PULUMI_ROOT=${PREFIX}

make -C sdk/go build
make -C sdk/go install

chmod -R u+w ${GOPATH}

rm -rf license-files

pushd sdk/go/pulumi-language-go

go-licenses save . --save_path=../../../license-files \
  --ignore github.com/pulumi/pulumi \
  --ignore github.com/mattn/go-localereader  

popd
pushd license-files

# The license file was added after the release was tagged, but the readme clearly states the license.
mkdir -p github.com/mattn/go-localereader
curl -o github.com/mattn/go-localereader/LICENSE https://raw.githubusercontent.com/mattn/go-localereader/master/LICENSE

popd
