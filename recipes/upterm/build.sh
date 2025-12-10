#!/bin/bash
set -euxo pipefail

export LDFLAGS="${LDFLAGS:-} -s -w -X github.com/owenthereal/upterm/internal/version.Version=${PKG_VERSION}"

go build -ldflags "${LDFLAGS}" -o "${PREFIX}/bin/upterm" ./cmd/upterm
go build -ldflags "${LDFLAGS}" -o "${PREFIX}/bin/uptermd" ./cmd/uptermd

go-licenses save ./cmd/upterm ./cmd/uptermd --save_path="${SRC_DIR}/license-files" || true
