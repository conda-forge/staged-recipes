#!/bin/sh
set -e

go env
go get github.com/google/go-licenses

export GOPATH=$(go env GOPATH)
export LIBRARY_LICENCES_PATH="$RECIPE_DIR/library_licenses/"
export TEMP_DIR=$(mktemp -d)
export KUBELOGIN_PATH="$TEMP_DIR/kubelogin"

echo $LIBRARY_LICENCES_PATH
echo $export

cd $TEMP_DIR
git clone https://github.com/Azure/kubelogin.git
cd kubelogin/

rm -fr $LIBRARY_LICENCES_PATH
$GOPATH/bin/go-licenses save $KUBELOGIN_PATH --save_path=$LIBRARY_LICENCES_PATH

cd $RECIPE_DIR
rm -fr $TEMP_DIR
