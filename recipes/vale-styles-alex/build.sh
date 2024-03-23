#!/usr/bin/env bash
export VALE_STYLES_PATH=${PREFIX}/share/vale/styles
mkdir -p "${VALE_STYLES_PATH}"

cp "${RECIPE_DIR}/.vale.ini" .vale.ini

vale sync
vale ls-config
vale ls-dirs

cp "LICENSE-vale-alex-0.2.1" LICENSE
