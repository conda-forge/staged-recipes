#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

pushd src
    go build -buildmode=pie -trimpath -o=${PREFIX}/bin/${PKG_NAME} -ldflags="-s -w -X main.Version=${PKG_VERSION}"
    go-licenses save . --save_path=../license-files \
        --ignore github.com/golang/freetype/raster \
        --ignore github.com/golang/freetype/truetype \
        --ignore github.com/jandedobbeleer/oh-my-posh \
        --ignore github.com/mattn/go-localereader
popd

cp -r themes ${PREFIX}
mkdir -p ${PREFIX}/share/${PKG_NAME}
ln -sf ${PREFIX}/theme ${PREFIX}/share/${PKG_NAME}

# Manually copy licenses that go-licenses could not download
cp -r ${RECIPE_DIR}/license-files/* ${SRC_DIR}/license-files
