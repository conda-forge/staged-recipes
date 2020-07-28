#!/bin/sh
set -e

go get github.com/google/go-licenses

echo "debug1"
echo "debug2"
echo "debug3"
which go
which go-licenses
echo "debug4"
echo "debug5"
echo "debug6"

export GOPATH=$(go env GOPATH)
export LIBRARY_LICENSES_PATH="$RECIPE_DIR/library_licenses/"

# Clone v0.16.1.
pushd $SRC_DIR
rm -fr $LIBRARY_LICENSES_PATH
$GOPATH/bin/go-licenses save "github.com/tilt-dev/tilt/cmd/tilt" --save_path=$LIBRARY_LICENSES_PATH
popd
