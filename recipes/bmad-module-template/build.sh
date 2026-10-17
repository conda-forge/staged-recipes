#!/usr/bin/env bash
set -euxo pipefail

if [ ! -f "README.md" ]; then
    echo "ERROR: README.md not found in SRC_DIR: $(pwd)" >&2
    ls -la
    exit 1
fi

SHARE="${PREFIX}/share/bmad-module-template"
mkdir -p "${SHARE}"
# Ship the full template tree. skills/ may be empty save for .gitkeep until
# upstream populates skills/my-skill/.
cp -r .claude-plugin skills docs "${SHARE}/"
cp README.md LICENSE "${SHARE}/"

# Cross-platform Python entry point that copies the template tree elsewhere.
mkdir -p "${PREFIX}/bin"
cp "${RECIPE_DIR}/bmad_module_template_init.py" "${PREFIX}/bin/bmad-module-template-init"
chmod +x "${PREFIX}/bin/bmad-module-template-init"
