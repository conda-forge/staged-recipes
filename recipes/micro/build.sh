#! /usr/bin/env bash

set -eoux pipefail


make build
make install

go-licenses save "${SRC_DIR}" --save_path=./thirdparty-licenses
