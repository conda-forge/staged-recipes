#!/usr/bin/env bash
set -euxo pipefail

if [ ! -f "package.json" ]; then
    echo "ERROR: package.json not found in SRC_DIR: $(pwd)" >&2
    ls -la
    exit 1
fi

INSTALL_DIR="${PREFIX}/lib/node_modules/${PKG_NAME}"
mkdir -p "${INSTALL_DIR}"

# Mirror the upstream package.json `files` array, plus package.json + LICENSE.
cp -r bin docs payload source "${INSTALL_DIR}/"
cp install.sh package.json README.md ref.png LICENSE "${INSTALL_DIR}/"

# install.sh is invoked with `bash install.sh ...` from the bin shim, but make
# sure it stays executable in case the user invokes it directly.
chmod +x "${INSTALL_DIR}/install.sh"
chmod +x "${INSTALL_DIR}/bin/bmad-story-automator"

# Wrapper bin that locates the installed package and invokes node.
mkdir -p "${PREFIX}/bin"
cat > "${PREFIX}/bin/bmad-story-automator" << 'WRAPPER'
#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec node "${SCRIPT_DIR}/../lib/node_modules/bmad-story-automator/bin/bmad-story-automator" "$@"
WRAPPER
chmod +x "${PREFIX}/bin/bmad-story-automator"
