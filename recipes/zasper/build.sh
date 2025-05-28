#!/bin/bash
set -eoux pipefail

make init
make build

install -m755 zasper "$PREFIX/bin/zasper"

go-licenses save . --save_path="./license-files/"
