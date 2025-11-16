#!/bin/bash

set -euxo pipefail

# Build the web UI
npm install
npm run build

# Disable CGO to avoid Security Framework API compatibility issues with macOS 10.13 SDK
# (SecTrustCopyCertificateChain and SecTrustEvaluateWithError require macOS 10.14+)
export CGO_ENABLED=0

# Build the main mailpit binary
go build -v -trimpath \
    -ldflags="-s -w -X 'github.com/axllent/mailpit/config.Version=${PKG_VERSION}'" \
    -o "${PREFIX}/bin/mailpit"

# Build the sendmail binary
cd sendmail
go build -v -trimpath \
    -ldflags="-s -w" \
    -o "${PREFIX}/bin/mailpit-sendmail"

# Save license information
cd "${SRC_DIR}"
go-licenses save . --save_path ./library_licenses
