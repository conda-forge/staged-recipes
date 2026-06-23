#!/usr/bin/env bash
set -euxo pipefail

if [ ! -d "skills/ppt-master" ]; then
    echo "ERROR: skills/ppt-master/ directory not found in SRC_DIR: $(pwd)" >&2
    ls -la
    exit 1
fi

SHARE="${PREFIX}/share/ppt-master"
mkdir -p "${SHARE}/skills"
cp -r skills/ppt-master "${SHARE}/skills/"
cp LICENSE README.md "${SHARE}/"

mkdir -p "${PREFIX}/bin"
cp "${RECIPE_DIR}/ppt_master_install.py" "${PREFIX}/bin/ppt-master-install"
chmod +x "${PREFIX}/bin/ppt-master-install"
