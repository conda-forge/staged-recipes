#!/bin/bash
set -euxo pipefail

# Upstream only publishes prebuilt Linux packages; unpack the RPM payload.
bsdtar -xf whiteboard.rpm

mkdir -p "${PREFIX}/bin" "${PREFIX}/share" "${PREFIX}/Menu"
cp -a usr/share/review "${PREFIX}/share/whiteboard"

# The RPM installs chrome-sandbox setuid root, which a conda package cannot
# reproduce; Electron falls back to its user-namespace sandbox.
chmod 0755 "${PREFIX}/share/whiteboard/chrome-sandbox"

# Same launchers as the RPM's /usr/bin scripts, pointed at this prefix.
cat > "${PREFIX}/bin/review" <<EOF
#!/bin/sh
export ELECTRON_RUN_AS_NODE=1
export DEV_FAST_REVIEW_DESKTOP_COMMAND="${PREFIX}/bin/review-desktop"
exec "${PREFIX}/share/whiteboard/review" "${PREFIX}/share/whiteboard/resources/app/review-runtime/dist/cli.js" "\$@"
EOF
cat > "${PREFIX}/bin/review-desktop" <<EOF
#!/bin/sh
unset ELECTRON_RUN_AS_NODE VSCODE_DEV VSCODE_CLI
exec "${PREFIX}/share/whiteboard/review" "\$@"
EOF
chmod 0755 "${PREFIX}/bin/review" "${PREFIX}/bin/review-desktop"

cp "${RECIPE_DIR}/whiteboard.json" "${PREFIX}/Menu/whiteboard.json"
cp usr/share/icons/hicolor/512x512/apps/review.png "${PREFIX}/Menu/whiteboard.png"
