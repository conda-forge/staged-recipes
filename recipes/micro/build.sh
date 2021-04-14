#! /usr/bin/env bash

set -eoux pipefail


make build
make install

go-licenses save "${SRC_DIR}/cmd/micro" --save_path=./thirdparty-licenses

# remove all go files incorrectly copied into thirdparty-licenses
pushd ./thirdparty-licenses/layeh.com/gopher-luar/
rm -fv !("LICENSE")
popd

