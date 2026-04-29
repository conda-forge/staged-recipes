#!/bin/bash
set -euo pipefail
export PYTHONIOENCODING=utf-8

# --------------------------------------------------------------------------
# 1. Copy packaging files from recipe dir into source tree
# --------------------------------------------------------------------------
cp "${RECIPE_DIR}/pyproject.toml" .
cp "${RECIPE_DIR}/ppt_master_install.py" skills/ppt-master/scripts/

# --------------------------------------------------------------------------
# 2. Create missing __init__.py (source_to_md has none)
# --------------------------------------------------------------------------
touch skills/ppt-master/scripts/source_to_md/__init__.py

# --------------------------------------------------------------------------
# 3. Patch config.py so it finds data at $PREFIX/share/ppt-master when
#    running as an installed entry point (not from the source tree).
#    Original code: PROJECT_ROOT = Path(__file__).parent.parent
#    That resolves to site-packages/../ after install, which is wrong.
# --------------------------------------------------------------------------
"${PYTHON}" - << 'EOF'
import sys
from pathlib import Path

path = Path("skills/ppt-master/scripts/config.py")
text = path.read_text(encoding="utf-8")

# Insert 'import sys' if not already present
if "\nimport sys\n" not in text:
    text = text.replace("from pathlib import Path\n", "import sys\nfrom pathlib import Path\n", 1)

# Replace the one-liner PROJECT_ROOT with an installed-path-aware version
OLD = "PROJECT_ROOT = Path(__file__).parent.parent"
NEW = (
    '_SCRIPTS_DIR = Path(__file__).parent\n'
    '_INSTALLED_SHARE = Path(sys.prefix) / "share" / "ppt-master"\n'
    'PROJECT_ROOT = (\n'
    '    _SCRIPTS_DIR.parent\n'
    '    if (_SCRIPTS_DIR.parent / "templates").exists()\n'
    '    else _INSTALLED_SHARE\n'
    ')\n'
    'del _INSTALLED_SHARE, _SCRIPTS_DIR'
)
assert OLD in text, f"Expected pattern not found in config.py:\n  {OLD}"
text = text.replace(OLD, NEW, 1)

path.write_text(text, encoding="utf-8")
print("Patched config.py for installed-path resolution")
EOF

# --------------------------------------------------------------------------
# 4. Install Python packages and entry points via pip
# --------------------------------------------------------------------------
"${PYTHON}" -m pip install . --no-deps --no-build-isolation -vv

# --------------------------------------------------------------------------
# 5. Copy skill data to $PREFIX/share/ppt-master/ (ASCII filenames only).
#    This is what ppt-master-install copies to ~/.claude/skills/ppt-master/.
# --------------------------------------------------------------------------
SHARE="${PREFIX}/share/ppt-master"
SKILL="skills/ppt-master"

mkdir -p "${SHARE}"

# Core skill files
cp "${SKILL}/SKILL.md" "${SHARE}/"

# References, workflows, spec files
cp -r "${SKILL}/references" "${SHARE}/"
cp -r "${SKILL}/workflows"  "${SHARE}/"

# Scripts (so the skill runs from share/ with correct relative paths)
cp -r "${SKILL}/scripts"    "${SHARE}/"

# Templates root docs
mkdir -p "${SHARE}/templates"
for f in README.md design_spec_reference.md spec_lock_reference.md; do
    [ -f "${SKILL}/templates/${f}" ] && cp "${SKILL}/templates/${f}" "${SHARE}/templates/"
done

# Charts and icons — entirely ASCII-named, safe to copy wholesale
cp -r "${SKILL}/templates/charts" "${SHARE}/templates/"
cp -r "${SKILL}/templates/icons"  "${SHARE}/templates/"

# Layouts — copy only ASCII-named subdirectories (skip CJK-named ones which
# would crash conda's inspect_artifacts on Windows due to cp1252 limitations)
mkdir -p "${SHARE}/templates/layouts"
for f in README.md layouts_index.json; do
    [ -f "${SKILL}/templates/layouts/${f}" ] && cp "${SKILL}/templates/layouts/${f}" "${SHARE}/templates/layouts/"
done
for dir in academic_defense ai_ops anthropic china_telecom_template exhibit \
            google_style government_blue government_red mckinsey medical_university \
            pixel_retro psychology_attachment smart_red; do
    src="${SKILL}/templates/layouts/${dir}"
    [ -d "${src}" ] && cp -r "${src}" "${SHARE}/templates/layouts/"
done
