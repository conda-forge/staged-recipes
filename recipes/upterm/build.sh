#!/bin/bash
set -euxo pipefail

export LDFLAGS="${LDFLAGS} -X github.com/owenthereal/upterm/internal/version.Version=${PKG_VERSION}"

go build -ldflags "${LDFLAGS}" -o "${PREFIX}/bin/upterm" ./cmd/upterm
go build -ldflags "${LDFLAGS}" -o "${PREFIX}/bin/uptermd" ./cmd/uptermd

go-licenses save ./cmd/upterm ./cmd/uptermd \
    --save_path="${SRC_DIR}/license-files" \
    --ignore github.com/owenthereal/upterm \
    --ignore github.com/tj/go-update \
    --ignore github.com/tj/go
