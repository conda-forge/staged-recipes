#!/usr/bin/env bash
set -euxo pipefail

# Upstream pins the bun version it releases with, conda-forge may lag behind
sed -i.bak 's/^if (!semver.satisfies(process.versions.bun, expectedBunVersionRange)) {/if (false) {/' packages/script/src/index.ts

export OPENCODE_VERSION="${PKG_VERSION}"
export OPENCODE_CHANNEL=latest

bun install --frozen-lockfile --ignore-scripts

pushd packages/opencode
npx --yes license-checker-rseidelsohn --production --plainVertical --out "${SRC_DIR}/third-party-licenses.txt"
bun run script/build.ts --single --skip-install

case "${target_platform}" in
  linux-64)      DIST=opencode-linux-x64 ;;
  linux-aarch64) DIST=opencode-linux-arm64 ;;
  osx-64)        DIST=opencode-darwin-x64 ;;
  osx-arm64)     DIST=opencode-darwin-arm64 ;;
esac
install -Dm755 "dist/${DIST}/bin/opencode" "${PREFIX}/bin/opencode"
popd
