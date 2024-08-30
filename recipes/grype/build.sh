#!/bin/bash
set -exuo pipefail

pushd cmd/grype

go-licenses save . \
    --save_path "${SRC_DIR}"/library_licenses \
    --ignore modernc.org/mathutil \
    --ignore github.com/xi2/xz

go build \
    -v \
    -o "${PREFIX}"/bin/grype \
    -ldflags="-X 'main.version=${PKG_VERSION}'"

popd

# Clear out cache to avoid file not removable warnings
chmod -R u+w "$(go env GOPATH)" && rm -r "$(go env GOPATH)"
