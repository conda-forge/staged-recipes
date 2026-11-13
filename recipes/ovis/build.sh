#!/usr/bin/env bash
set -euxo pipefail

# Client (dist/) and the dependencies it is built from
bun install --frozen-lockfile
bun run build

# Rust PTY host
(cd crates/pty-sidecar && cargo-bundle-licenses --format yaml --output "${SRC_DIR}/THIRDPARTY.yml")
cargo install --locked --no-track --root "${SRC_DIR}/sidecar" --path crates/pty-sidecar
mkdir -p "${PREFIX}/libexec/ovis" "${PREFIX}/bin"
install -m755 "${SRC_DIR}/sidecar/bin/ovis-pty-sidecar" "${PREFIX}/libexec/ovis/ovis-pty-sidecar"

# Server sources, run by bun from the environment, and the client build
share="${PREFIX}/share/ovis"
mkdir -p "${share}/scripts"
cp -R dist server shared integrations package.json "${share}/"
cp scripts/install-gjc-integration.ts scripts/install-pi-integration.ts "${share}/scripts/"
find "${share}/server" "${share}/shared" "${share}/integrations" "${share}/scripts" \
  \( -name '*.test.ts' -o -name '*.fake.ts' -o -name '*.fixture.ts' \) -delete
rm -rf "${share}/server/fixtures"

# The server's runtime npm packages, and the licenses of all shipped npm packages
bun "${RECIPE_DIR}/collect-node-modules.ts" "${share}/node_modules" "${SRC_DIR}/ThirdPartyLicenses.txt" \
  "${share}/server" "${share}/shared" "${share}/integrations" "${share}/scripts"

# Launcher
sed "s/@VERSION@/${PKG_VERSION}/" "${RECIPE_DIR}/ovis.sh" > "${PREFIX}/bin/ovis"
chmod 755 "${PREFIX}/bin/ovis"
