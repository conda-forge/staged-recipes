#!/bin/bash

set -euxo pipefail

export GO111MODULE=on
make deps

# XXX We should run "make prerelease" here instead but that fails for some reason
make ember-dist static-assets

# XXX cross osx-arm64 not tested.
case "$target_platform" in
  linux-64)
    target=linux_amd64
    ;;
  linux-aarch64)
    target=linux_arm64
    ;;
  osx-64)
    target=darwin_amd64
    ;;
  osx-arm64)
    target=darwin_arm64
    ;;
  *)
    echo "target_platform $target_platform not supported" >&2
    exit 1
    ;;
esac
make pkg/$target/nomad

# XXX Workaround for "make" above installing lots of things into $PREFIX/bin.
rm $PREFIX/bin/*
cp pkg/$target/nomad $PREFIX/bin

# Nomad is a bit tricky with its licenses.
# If we are not careful, it will end in a loop.
# The ignored licenses are added manually in the recipe definition.
chmod -R u+rw gopath
rm -rf gopath
export GOPATH=$(dirname $(pwd))
go-licenses save . --save_path=./license-files \
	--ignore github.com/hashicorp/nomad/api \
	--ignore github.com/hashicorp/cronexpr \
	--ignore github.com/tj/go-spin \
	--ignore github.com/hashicorp/nomad
