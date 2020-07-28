#!/bin/sh
set -e

go get github.com/google/go-licenses

export LIBRARY_LICENSES_PATH="$RECIPE_DIR/library_licenses/"

# Clone v0.16.1.
pushd $SRC_DIR
rm -rf $LIBRARY_LICENSES_PATH
${PREFIX}/bin/go-licenses save "github.com/tilt-dev/tilt/cmd/tilt" --save_path=$LIBRARY_LICENSES_PATH
popd
