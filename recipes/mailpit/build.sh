#!/bin/bash

set -euxo pipefail

# Build the web UI
npm install
npm run build


# Build the main mailpit binary
go build -v \
    -ldflags="-s -w -X 'github.com/axllent/mailpit/config.Version=${PKG_VERSION}'" \
    -o "${PREFIX}/bin/mailpit"

# Build the sendmail binary
cd sendmail
go build -v \
    -ldflags="-s -w" \
    -o "${PREFIX}/bin/mailpit-sendmail"

# Save license information
cd "${SRC_DIR}"
go-licenses save . --save_path ./library_licenses
