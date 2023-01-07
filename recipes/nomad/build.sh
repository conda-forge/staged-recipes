#!/bin/bash

set -euxo pipefail

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

# XXX Running go-licenses doesn't currently work; fails after creating 40 GB (!) worth of license files.
# Ignore warning about go-spin (MIT licensed)
# go-licenses save . --save_path=./license-files || true
