#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go build -buildmode=pie -trimpath -o=${PREFIX}/libexec/spicetify-cli/bin/spicetify-cli -ldflags="-s -w"
cp css-map.json ${PREFIX}/libexec/spicetify-cli
cp -R CustomApps ${PREFIX}/libexec/spicetify-cli
cp -R Extensions ${PREFIX}/libexec/spicetify-cli
cp globals.d.ts ${PREFIX}/libexec/spicetify-cli
cp -R jsHelper ${PREFIX}/libexec/spicetify-cli
cp -R Themes ${PREFIX}/libexec/spicetify-cli
mkdir -p ${PREFIX}/bin
ln -sf ${PREFIX}/libexec/spicetify-cli/bin/spicetify-cli ${PREFIX}/bin/spicetify-cli

go-licenses save . --save_path=license-files --ignore github.com/spicetify/cli
