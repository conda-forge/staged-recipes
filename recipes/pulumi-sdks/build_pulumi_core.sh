#!/bin/bash

set -exuo pipefail

mkdir -p gopath/bin
export GOPATH=$(pwd)/gopath

export PULUMI_VERSION=${PKG_VERSION}
export PULUMI_ROOT=${PREFIX}

make build
make install

chmod -R u+w ${GOPATH}

pushd pkg/cmd/pulumi

go-licenses save . --save_path=../../../license-files \
  --ignore github.com/pulumi/pulumi \
  --ignore github.com/mattn/go-localereader \
  --ignore github.com/sourcegraph/appdash-data

popd
pushd license-files


# The license file was added after the release was tagged, but the readme clearly states the license.
mkdir -p github.com/mattn/go-localereader
curl -o github.com/mattn/go-localereader/LICENSE https://raw.githubusercontent.com/mattn/go-localereader/master/LICENSE


# The appdash-data package uses and eclectic mix of licenses that are linked from the readme.
mkdir -p github.com/sourcegraph/appdash-data
pushd github.com/sourcegraph/appdash-data
curl -o LICENSE https://raw.githubusercontent.com/sourcegraph/appdash/master/LICENSE

mkdir -p benkeen/d3pie
curl -o benkeen/d3pie/LICENSE https://raw.githubusercontent.com/benkeen/d3pie/master/LICENSE

# Upstream only states MIT in the README, but does not provide a license file
mkdir -p jiahuang/d3-timeline
echo "MIT" >jiahuang/d3-timeline/LICENSE

mkdir -p krisk/fuse
curl -o krisk/fuse/LICENSE https://raw.githubusercontent.com/krisk/Fuse/main/LICENSE

mkdir -p zeroclipboard/zeroclipboard
curl -o zeroclipboard/zeroclipboard/LICENSE https://raw.githubusercontent.com/zeroclipboard/zeroclipboard/master/LICENSE
popd

popd
