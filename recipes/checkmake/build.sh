#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

export BUILDER_NAME="conda-forge"
export BUILDER_EMAIL="conda@conda-forge.org"

make
make install
go-licenses save . --save_path=license-files
