#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go build -buildmode=pie -trimpath -modcacherw -o=${PREFIX}/bin/${PKG_NAME} -ldflags="-s -w" ./cli
go-licenses save ./cli --save_path=license-files
