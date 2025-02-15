#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go build -v -o=${PREFIX}/bin/freeze
go-licenses save . --save_path=license-files
