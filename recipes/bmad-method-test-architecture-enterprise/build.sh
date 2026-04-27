#!/usr/bin/env bash
set -euxo pipefail

if [ ! -d "src" ]; then
    echo "ERROR: src/ directory not found in SRC_DIR: $(pwd)" >&2
    ls -la
    exit 1
fi

SHARE="${PREFIX}/share/bmad-method-test-architecture-enterprise"
mkdir -p "${SHARE}"
cp -r src/agents "${SHARE}/"
cp -r src/workflows "${SHARE}/"
cp src/module-help.csv src/module.yaml "${SHARE}/"
cp -r .claude-plugin "${SHARE}/"
cp CHANGELOG.md LICENSE README.md "${SHARE}/"

mkdir -p "${PREFIX}/bin"
cp "${RECIPE_DIR}/bmad_tea_install.py" "${PREFIX}/bin/bmad-tea-install"
chmod +x "${PREFIX}/bin/bmad-tea-install"
