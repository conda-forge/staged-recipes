#!/bin/sh
SYMPOW_LOCAL="$HOME"/.local/share/sympow

if [ ! -d "${SYMPOW_LOCAL}" ]; then
    mkdir -p "${SYMPOW_LOCAL}"
    cp -r "${CONDA_PREFIX}"/share/sympow/* "${SYMPOW_LOCAL}"
fi
cd "$SYMPOW_LOCAL"
exec sympow_bin "$@"
