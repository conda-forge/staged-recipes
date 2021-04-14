#! /usr/bin/env bash

set -eoux pipefail


make build
make install

go-licenses save "${SRC_DIR}/cmd/micro" --save_path="${RECIPE_DIR}/thirdparty-licenses/"
