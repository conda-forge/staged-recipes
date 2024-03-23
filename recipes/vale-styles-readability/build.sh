#!/usr/bin/env bash
export VALE_STYLES_PATH=${PREFIX}/share/vale/styles
mkdir -p "${VALE_STYLES_PATH}"

echo "Packages = ./Readability" >> .vale.ini
echo "StylesPath = ${VALE_STYLES_PATH}" >> .vale.ini

vale sync
vale ls-config
vale ls-dirs

cp "LICENSE-vale-Readability-0.1.1" LICENSE
