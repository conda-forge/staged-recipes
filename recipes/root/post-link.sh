#!/usr/bin/env bash
# Enable bash strict mode
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

(
    cd "${PREFIX}" || exit 1
    export ROOTIGNOREPREFIX=1
    python "${PREFIX}/etc/dictpch/makepch.py" "${PREFIX}/etc/allDict.cxx.pch" -I"${PREFIX}/include"
) >> "${PREFIX}/.messages.txt" 2>&1
