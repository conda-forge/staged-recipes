#!/bin/bash
set -euxo pipefail

cd src

# Build frontend
cd frontend && npm install && npm run build && cd ..

# Copy frontend dist to web embed directory
rm -rf internal/web/dist && cp -r frontend/dist internal/web/dist

# Install wails CLI
go install github.com/wailsapp/wails/v2/cmd/wails@latest

# Collect Go dependency licenses
go-licenses save . --save_path ../library_licenses

# Build desktop app
if [[ "$(uname)" == "Linux" ]]; then
    wails build -tags webkit2_41 -ldflags "-s -w -X main.Version=${PKG_VERSION}"
    cp build/bin/Nebi "${PREFIX}/bin/nebi-desktop"
    rm -f "${PREFIX}/bin/wails"
elif [[ "$(uname)" == "Darwin" ]]; then
    wails build -ldflags "-s -w -X main.Version=${PKG_VERSION}"
    mkdir -p "${PREFIX}/Applications"
    cp -r build/bin/Nebi.app "${PREFIX}/Applications/Nebi.app"
fi
