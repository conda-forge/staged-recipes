#!/usr/bin/env bash
set -euxo pipefail

if [ ! -d "skills" ]; then
    echo "ERROR: skills/ directory not found in SRC_DIR: $(pwd)" >&2
    ls -la
    exit 1
fi

# Install skill files and Claude plugin config
mkdir -p "${PREFIX}/share/bmad-builder"
cp -r skills "${PREFIX}/share/bmad-builder/"
cp -r .claude-plugin "${PREFIX}/share/bmad-builder/"
cp CHANGELOG.md LICENSE README.md "${PREFIX}/share/bmad-builder/"

# Install cross-platform Python entry point
mkdir -p "${PREFIX}/bin"
cp "${RECIPE_DIR}/bmad_builder_install.py" "${PREFIX}/bin/bmad-builder-install"
chmod +x "${PREFIX}/bin/bmad-builder-install"
