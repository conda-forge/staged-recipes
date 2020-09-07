#!/bin/sh
set -e

export GOBIN=$(go env GOBIN)
export LIBRARY_LICENCES_PATH="$RECIPE_DIR/library_licenses/"
export TEMP_DIR=$(mktemp -d)
export KUBELOGIN_PATH="$TEMP_DIR/kubelogin"

go get -v github.com/google/go-licenses

cd $TEMP_DIR
git clone https://github.com/Azure/kubelogin.git
cd kubelogin/

rm -fr $LIBRARY_LICENCES_PATH
$GOBIN/bin/go-licenses save $KUBELOGIN_PATH --save_path=$LIBRARY_LICENCES_PATH

cd $RECIPE_DIR
rm -fr $TEMP_DIR
