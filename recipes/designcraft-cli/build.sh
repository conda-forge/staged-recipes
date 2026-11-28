#!/usr/bin/env bash
set -euxo pipefail

# Embed the CJK/extra-script fonts, as the upstream release builds do
export CRAFT_FONTS_DIR="${SRC_DIR}/craft-fonts"
export CRAFT_FONTS_REQUIRED=1

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml

cargo auditable install --locked --no-track --bins --root "${PREFIX}" --path apps/designcraft-cli
