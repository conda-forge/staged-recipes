#!/bin/sh
set -e

export GOBIN=$(go env GOBIN)
export THIRDPARTY_LICENCES_PATH="$RECIPE_DIR/thirdparty_licenses/"

rm -fr $THIRDPARTY_LICENCES_PATH
go get -v github.com/google/go-licenses
$GOBIN/go-licenses save $SRC_DIR --save_path=$THIRDPARTY_LICENCES_PATH
