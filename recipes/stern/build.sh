#!/bin/sh

export GOBIN="$PREFIX/bin"

# https://github.com/stern/stern/blob/v1.21.0/.goreleaser.yaml#L7-L9
LDFLAGS="-X github.com/stern/stern/cmd.version=$PKG_VERSION-$PKG_BUILDNUM"

go install -v -ldflags="$LDFLAGS" .

go-licenses save . --save_path=./license-files
test -d license-files/github.com
