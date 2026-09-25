#!/usr/bin/env bash

set -eux

go build -v \
    -trimpath \
    -modcacherw \
    -ldflags="-w -s -X main.version=${PKG_VERSION}" \
    -o "${PREFIX}/bin/gha-doctor" \
    ./cmd/gha-doctor

"${PREFIX}/bin/gha-doctor" --version

go-licenses save ./cmd/gha-doctor --save_path library_licenses
