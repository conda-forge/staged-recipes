#!/usr/bin/env bash
set -euxo pipefail

# Link conda-forge's libghostty-vt and generate the bindings from its headers
# instead of building the vendored Ghostty submodule with Zig.
export GHOSTTY_VT_LIB_DIR="${PREFIX}/lib"
export GHOSTTY_VT_INCLUDE_DIR="${PREFIX}/include"

# bindgen loads libclang at runtime; libclang has no C library headers of its own.
export LIBCLANG_PATH="${BUILD_PREFIX}/lib"
if [[ "${target_platform}" == linux-* ]]; then
    export BINDGEN_EXTRA_CLANG_ARGS="--sysroot=$(${CC} -print-sysroot)"
else
    export BINDGEN_EXTRA_CLANG_ARGS="-isysroot ${CONDA_BUILD_SYSROOT}"
fi

# Use conda-forge's zstd instead of the copy bundled with zstd-sys.
export ZSTD_SYS_USE_PKG_CONFIG=1

export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_PROFILE_RELEASE_LTO=fat

# HERDR_APP_RELEASE stays unset: no self-updates and no telemetry endpoint.
cargo auditable install --locked --no-track --bin herdr-app --root "${PREFIX}" --path .
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

mkdir -p "${PREFIX}/Menu"
cp "${RECIPE_DIR}/Menu/herdr-app.json" "${PREFIX}/Menu/herdr-app.json"

if [[ "${target_platform}" == osx-* ]]; then
    # A real app bundle, so the Dock shows Herdr's name and icon (same layout
    # as upstream's scripts/package).
    app="${PREFIX}/Applications/Herdr.app"
    mkdir -p "${app}/Contents/MacOS" "${app}/Contents/Resources"
    mv "${PREFIX}/bin/herdr-app" "${app}/Contents/MacOS/Herdr"
    cp assets/icons/Herdr.icns "${app}/Contents/Resources/Herdr.icns"
    sed "s/@VERSION@/${PKG_VERSION}/g" "${RECIPE_DIR}/Info.plist" > "${app}/Contents/Info.plist"
    cat > "${PREFIX}/bin/herdr-app" <<'EOF'
#!/bin/sh
exec "$(dirname "$0")/../Applications/Herdr.app/Contents/MacOS/Herdr" "$@"
EOF
    chmod +x "${PREFIX}/bin/herdr-app"
    cp assets/icons/Herdr.icns "${PREFIX}/Menu/herdr-app.icns"
else
    cp assets/icons/herdr-ui-icon-clean.png "${PREFIX}/Menu/herdr-app.png"
    mkdir -p "${PREFIX}/share/icons/hicolor/scalable/apps"
    cp assets/icons/herdr-ui-icon-clean.svg "${PREFIX}/share/icons/hicolor/scalable/apps/herdr-app.svg"
fi
