#! /usr/bin/env bash

set -eoux pipefail


make build
make install

go-licenses save "${SRC_DIR}/cmd/micro" --save_path=./thirdparty-licenses

cat /home/conda/staged-recipes/build_artifacts/micro_1618364822272/work/thirdparty-licenses/layeh.com/gopher-luar/array_test.go
