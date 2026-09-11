#!/bin/bash
set -euxo pipefail

SHARE="${PREFIX}/share/bmad-dashboard"
mkdir -p "${SHARE}" "${PREFIX}/bin"

# Sources arrive in $SRC_DIR named exactly per the recipe's file_name fields.
cp "${SRC_DIR}/bmad-dashboard-${PKG_VERSION}.vsix" "${SHARE}/"
cp "${SRC_DIR}/LICENSE.md"                         "${SHARE}/"
cp "${RECIPE_DIR}/bmad_dashboard_install.py"       "${SHARE}/"

# Unix entry point: a thin shell wrapper around the bundled Python helper.
cat > "${PREFIX}/bin/bmad-dashboard-install" <<'SH'
#!/bin/sh
exec python "${CONDA_PREFIX}/share/bmad-dashboard/bmad_dashboard_install.py" "$@"
SH
chmod +x "${PREFIX}/bin/bmad-dashboard-install"
