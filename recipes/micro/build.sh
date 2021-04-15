#! /usr/bin/env bash

set -eoux pipefail


make build
make install
make test

go-licenses save "${SRC_DIR}/cmd/micro" --save_path="${RECIPE_DIR}/thirdparty-licenses/"
