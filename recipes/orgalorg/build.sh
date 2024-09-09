#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go build -mod=mod -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="-s -w -X main.version=${PKG_VERSION}"
go-licenses save . --save_path=license-files \
	--ignore github.com/kovetskiy/lorg \
	--ignore github.com/reconquest/nopio-go \
	--ignore github.com/reconquest/prefixwriter-go \
	--ignore github.com/reconquest/runcmd \
	--ignore github.com/zazab/zhash

# Manually copy licenses that go-licenses could not download
cp -r ${RECIPE_DIR}/license-files/* ${SRC_DIR}/license-files
