#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

sed -i "s/os.Mkdir(/os.MkdirAll(/g" tools/build_gcsfuse/main.go
go build ./tools/build_gcsfuse
./build_gcsfuse ${SRC_DIR} ${PREFIX} ${PKG_VERSION}
go-licenses save . --save_path=license-files
