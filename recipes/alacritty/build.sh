#!/bin/bash

set -ex

export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_PROFILE_RELEASE_LTO=fat

cargo-bundle-licenses --format yaml --output ${SRC_DIR}/THIRDPARTY.yml

mkdir -p "${PREFIX}/Menu"
sed -e "s/__PKG_VERSION__/${PKG_VERSION}/g" -e "s/__PKG_MAJOR_VER__/${PKG_VERSION%%.*}/g" "${RECIPE_DIR}/menu.json" > "${PREFIX}/Menu/${PKG_NAME}_menu.json"
install -m0644 "${RECIPE_DIR}/alacritty.icns" "${PREFIX}/Menu/alacritty.icns"

cargo auditable install --locked --no-track --path ./alacritty --target ${CARGO_BUILD_TARGET} --root ${PREFIX}
rm -rf target
