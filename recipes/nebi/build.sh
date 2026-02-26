#!/bin/bash
set -euxo pipefail

cd src

# Build frontend
cd frontend && npm install && npm run build && cd ..

# Copy frontend dist to web embed directory
rm -rf internal/web/dist && cp -r frontend/dist internal/web/dist

# Collect Go dependency licenses
go-licenses save ./cmd/nebi --save_path ../library_licenses

# Build the binary
go build -v -o "${PREFIX}/bin/nebi" -ldflags="-s -w -X main.Version=${PKG_VERSION}" ./cmd/nebi
