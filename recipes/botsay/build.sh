#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go build -buildmode=pie -trimpath -modcacherw -o=${PREFIX}/bin/botsay -ldflags="-s -w"
go-licenses save . --save_path=license-files
