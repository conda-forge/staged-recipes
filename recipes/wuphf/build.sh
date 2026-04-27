#!/usr/bin/env bash
set -euxo pipefail

module="github.com/nex-crm/wuphf"

cd "${SRC_DIR}"

# Mirror upstream .goreleaser.yml: pure-Go build, no CGO.
export CGO_ENABLED=0
export GOFLAGS="-mod=mod"

# Honor SOURCE_DATE_EPOCH for reproducible BuildTimestamp injection.
# GNU date (Linux) uses `-d @<epoch>`; BSD date (macOS) uses `-r <epoch>`.
if [[ -n "${SOURCE_DATE_EPOCH:-}" ]]; then
    if build_iso=$(date -u -r "${SOURCE_DATE_EPOCH}" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null); then
        :
    else
        build_iso=$(date -u -d "@${SOURCE_DATE_EPOCH}" +%Y-%m-%dT%H:%M:%SZ)
    fi
else
    build_iso=$(date -u +%Y-%m-%dT%H:%M:%SZ)
fi

go build \
    -trimpath \
    -ldflags "-s -w \
        -X ${module}/internal/buildinfo.Version=${PKG_VERSION} \
        -X ${module}/internal/buildinfo.BuildTimestamp=${build_iso}" \
    -o "${PREFIX}/bin/${PKG_NAME}" \
    ./cmd/wuphf

go-licenses save ./cmd/wuphf --save_path "${SRC_DIR}/license-files" --force
