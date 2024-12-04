#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go build -buildmode=pie -trimpath -o=${PREFIX}/bin/akita-cli -ldflags="-s -w"
go-licenses save . --save_path=license-files --ignore github.com/akitasoftware/plugin-flickr
