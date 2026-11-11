#!/usr/bin/env bash
set -euxo pipefail

if [ ! -d "skills" ]; then
    echo "ERROR: skills/ directory not found in SRC_DIR: $(pwd)" >&2
    ls -la
    exit 1
fi

SHARE="${PREFIX}/share/bmad-utility-skills"
mkdir -p "${SHARE}"
cp -r skills "${SHARE}/"
cp -r .claude-plugin "${SHARE}/"
cp README.md AGENTS.md CLAUDE.md "${SHARE}/"

# Upstream does not yet ship a LICENSE file (tracked: hold submission).
# Use the MIT LICENSE vendored alongside this recipe.
cp "${RECIPE_DIR}/LICENSE" "${SHARE}/"

# Cross-platform Python entry point
mkdir -p "${PREFIX}/bin"
cp "${RECIPE_DIR}/bmad_utility_skills_install.py" "${PREFIX}/bin/bmad-utility-skills-install"
chmod +x "${PREFIX}/bin/bmad-utility-skills-install"
