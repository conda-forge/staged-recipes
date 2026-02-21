#!/bin/bash

set -ex

export PKG_CONFIG=$BUILD_PREFIX/bin/pkg-config

export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_PROFILE_RELEASE_LTO=fat

cargo-bundle-licenses --format yaml --output ${SRC_DIR}/THIRDPARTY.yml

mkdir -p "${PREFIX}/Menu"
sed -e "s/__PKG_VERSION__/${PKG_VERSION}/g" "${RECIPE_DIR}/menu.json" > "${PREFIX}/Menu/${PKG_NAME}_menu.json"
if [[ $OSTYPE == "darwin"* ]]; then
  cp "${RECIPE_DIR}/alacritty.icns" "${PREFIX}/Menu/alacritty.icns"
else
  cp "${RECIPE_DIR}/alacritty.png" "${PREFIX}/Menu/alacritty.png"
fi

cargo auditable install --locked --no-track --path ./alacritty --target ${CARGO_BUILD_TARGET} --root ${PREFIX}
rm -rf target
