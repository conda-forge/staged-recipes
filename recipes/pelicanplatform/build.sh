#!/bin/bash

set -ex

export CGO_ENABLED=0

go generate ./...

cd "origin_ui/src"
npm install
npm run build

cd "${SRC_DIR}"
go build \
  -a \
  -ldflags "-w -s -X main.version=${PKG_VERSION} -X main.commit=v${PKG_VERSION} -X main.date=$(date -u +"%Y-%m-%dT%H:%M:%SZ") -X main.builtBy=conda-forge" \
  -tags forceposix \
  -p ${CPU_COUNT} \
  -v \
  -o "${PREFIX}/bin/pelican" \
  ./cmd

# generate the license pack
go get ./...
go-licenses save ./cmd --save_path license-files --ignore modernc.org\/mathutil
