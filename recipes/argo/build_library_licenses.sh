#!/bin/sh
set -e

# conda install -y go-cgo

go get github.com/google/go-licenses

export GOPATH=$(go env GOPATH)
export RECIPE_DIR=$(pwd)
export LIBRARY_LICENCES_PATH="$RECIPE_DIR/library_licenses/"
export TEMP_DIR=$(mktemp -d)
export ARGO_PATH="$TEMP_DIR/argo"

cd $TEMP_DIR
git clone https://github.com/argoproj/argo.git
cd argo/
git checkout v2.8.1

rm -fr $LIBRARY_LICENCES_PATH
$GOPATH/bin/go-licenses save $ARGO_PATH --save_path=$LIBRARY_LICENCES_PATH

cd $RECIPE_DIR
rm -fr $TEMP_DIR
