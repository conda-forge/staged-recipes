#!/bin/bash
set -euxo pipefail
IFS=$'\n\t'

# Enable CGO for native library support
export CGO_ENABLED=1
export GOFLAGS="-mod=readonly"

# Set up pkg-config for finding libraries
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH:-}"
export CGO_CFLAGS="-I${PREFIX}/include"
export CGO_LDFLAGS="-L${PREFIX}/lib"

# Build version info
COMMIT="conda-forge-${PKG_VERSION}"

# Build ipsw with version information embedded
go build \
    -ldflags "-s -w \
        -X github.com/blacktop/ipsw/cmd/ipsw/cmd.AppVersion=${PKG_VERSION} \
        -X github.com/blacktop/ipsw/cmd/ipsw/cmd.AppBuildCommit=${COMMIT}" \
    -o "${PREFIX}/bin/ipsw" \
    ./cmd/ipsw

# Verify the binary was built
"${PREFIX}/bin/ipsw" version
