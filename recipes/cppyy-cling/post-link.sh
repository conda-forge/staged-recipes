#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

if [ "$(uname)" == "Linux" ]; then
    (
        cd "${PREFIX}" || exit 1
        export ROOTIGNOREPREFIX=1
        python "${PREFIX}/etc/dictpch/makepch.py" "${PREFIX}/etc/allDict.cxx.pch" -I"${PREFIX}/include"
    ) >> "${PREFIX}/.messages.txt" 2>&1
fi
