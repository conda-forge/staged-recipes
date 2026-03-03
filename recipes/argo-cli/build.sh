#!/bin/bash
set -exuo pipefail

JOBS=max yarn --cwd ui install --frozen-lockfile
JOBS=max yarn --cwd ui build
go build \
    -v \
    -gcflags '' \
    -ldflags "-X 'github.com/argoproj/argo-workflows/v3.version=v${PKG_VERSION}'" \
    -o "${PREFIX}/bin/argo" \
    ./cmd/argo/

# save thirdparty licenses
# FIXME: unknown license jmespath
go-licenses save ./cmd/argo --ignore github.com/jmespath/go-jmespath --save_path ./library_licenses/
