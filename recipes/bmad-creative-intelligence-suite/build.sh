#!/usr/bin/env bash
set -euxo pipefail

if [ ! -d "src" ]; then
    echo "ERROR: src/ directory not found in SRC_DIR: $(pwd)" >&2
    ls -la
    exit 1
fi

SHARE="${PREFIX}/share/bmad-creative-intelligence-suite"
mkdir -p "${SHARE}"
cp -r src/skills "${SHARE}/"
cp src/module-help.csv src/module.yaml "${SHARE}/"
cp CHANGELOG.md LICENSE README.md "${SHARE}/"

mkdir -p "${PREFIX}/bin"
cp "${RECIPE_DIR}/bmad_cis_install.py" "${PREFIX}/bin/bmad-cis-install"
chmod +x "${PREFIX}/bin/bmad-cis-install"
