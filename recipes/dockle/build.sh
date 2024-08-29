#!/bin/bash
set -exuo pipefail

pushd cmd/dockle

go-licenses save . \
    --save_path "${SRC_DIR}"/library_licenses \
    --ignore github.com/goodwithtech/deckoder

go build \
    -v \
    -o "${PREFIX}"/bin/dockle \
    -ldflags="-X 'github.com/goodwithtech/dockle/pkg.version=${PKG_VERSION}'"

popd

# Clear out cache to avoid file not removable warnings
chmod -R u+w "$(go env GOPATH)" && rm -r "$(go env GOPATH)"
