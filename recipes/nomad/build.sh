#!/bin/bash

set -euo pipefail

make deps

# TODO make prerelease
make ember-dist static-assets

# TODO: cross osx-arm64
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

# TODO
rm $PREFIX/bin/*
cp pkg/$target/nomad $PREFIX/bin

# Ignore warning about go-spin (MIT licensed)
go-licenses save . --save_path=./license-files || true
test -d license-files/github.com
