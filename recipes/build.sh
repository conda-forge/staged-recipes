#!/bin/bash
set -ex

# Enable CGO for SQLite support
export CGO_ENABLED=1

# Set Go build flags
export GOFLAGS="-buildmode=pie -trimpath -mod=readonly -modcacherw"

# Version from conda build
VERSION="${PKG_VERSION}"

# Collect licenses from Go dependencies first
mkdir -p "${SRC_DIR}/library_licenses"
go-licenses save ./... --save_path="${SRC_DIR}/library_licenses" --ignore=github.com/writefreely/writefreely || true

# Build the writefreely binary with SQLite and netgo support
# - 'sqlite' tag enables SQLite database support (requires CGO)
# - 'netgo' tag uses pure Go network implementations
cd cmd/writefreely
go build -v \
    -tags='netgo sqlite' \
    -ldflags="-s -w -X 'github.com/writefreely/writefreely.softwareVer=${VERSION}'" \
    -o "${PREFIX}/bin/writefreely" \
    .
cd ../..

# Copy static assets and templates that WriteFreely needs at runtime
# Users need to copy these to their working directory when running WriteFreely
mkdir -p "${PREFIX}/share/writefreely"
cp -r pages "${PREFIX}/share/writefreely/" 2>/dev/null || true
cp -r templates "${PREFIX}/share/writefreely/" 2>/dev/null || true
cp -r static "${PREFIX}/share/writefreely/" 2>/dev/null || true
cp -r keys "${PREFIX}/share/writefreely/" 2>/dev/null || true
cp schema.sql "${PREFIX}/share/writefreely/" 2>/dev/null || true
cp sqlite.sql "${PREFIX}/share/writefreely/" 2>/dev/null || true
