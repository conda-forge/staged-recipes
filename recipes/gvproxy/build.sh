#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

go build -buildmode=pie -trimpath -o=${PREFIX}/bin/gvproxy -ldflags="-s -w" ./cmd/gvproxy
go build -buildmode=pie -trimpath -o=${PREFIX}/bin/qemu-wrapper -ldflags="-s -w" ./cmd/qemu-wrapper
go-licenses save ./cmd/gvproxy --save_path=license-files_gvproxy
go-licenses save ./cmd/qemu-wrapper --save_path=license-files_qemu-wrapper

if [[ ${target_platform} =~ .*linux.* ]]; then
    go build -buildmode=pie -trimpath -o=${PREFIX}/bin/vm -ldflags="-s -w" ./cmd/vm
    go-licenses save ./cmd/vm --save_path=license-files_vm
fi
