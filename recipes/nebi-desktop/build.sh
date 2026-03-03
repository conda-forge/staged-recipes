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
if [[ "${target_platform}" == "linux-"* ]]; then
    wails build -tags webkit2_41 -ldflags "-s -w -X main.Version=${PKG_VERSION}"
    cp build/bin/Nebi "${PREFIX}/bin/nebi-desktop"
    rm -f "${PREFIX}/bin/wails"
elif [[ "${target_platform}" == "osx-"* ]]; then
    wails build -ldflags "-s -w -X main.Version=${PKG_VERSION}"
    cp build/bin/Nebi.app/Contents/MacOS/Nebi "${PREFIX}/bin/nebi-desktop"
    rm -f "${PREFIX}/bin/wails"
fi

# Install menuinst menu config and icons
mkdir -p "${PREFIX}/Menu"
sed "s/__PKG_VERSION__/${PKG_VERSION}/g" "${RECIPE_DIR}/nebi-desktop-menu.json" > "${PREFIX}/Menu/nebi-desktop-menu.json"
if [[ "${target_platform}" == "osx-"* ]]; then
    cp "${RECIPE_DIR}/nebi.icns" "${PREFIX}/Menu/nebi.icns"
else
    cp "${RECIPE_DIR}/nebi.png" "${PREFIX}/Menu/nebi.png"
fi
