#! /usr/bin/env bash

set -eoux pipefail


make build
make install

go-licenses save "github.com/zyedidia/micro" --save_path=./thirdparty-licenses
