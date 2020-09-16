#!/bin/bash
set -ex


GOBIN=$(go env GOBIN)
export GOBIN=$GOBIN

go get -v github.com/google/go-licenses

$GOBIN/go-licenses save $SRC_DIR --save_path="$RECIPE_DIR/thirdparty_licenses/"
