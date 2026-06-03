#!/usr/bin/env bash
set -euo pipefail

# Repack the extracted package into a tarball, then install that tarball into the
# prefix. Installing from a tarball (rather than the unpacked folder) makes npm
# resolve and install the full dependency tree pinned by npm-shrinkwrap.json,
# including the sibling @earendil-works/pi-{ai,agent-core,tui} packages and the
# vendored prebuilt native addons.
mkdir -p "${SRC_DIR}/packed"
( cd "${SRC_DIR}/app" && npm pack --pack-destination "${SRC_DIR}/packed" )
npm install -g --prefix "${PREFIX}" "${SRC_DIR}/packed"/*.tgz

# pi-tui's npm package bundles prebuilt native addons for every OS/arch in a
# single tarball. Keep only the prebuild matching this target platform and drop
# the rest, so each package ships exactly the binary it can load. (Keyed on the
# conda target_platform, so this is correct under cross-compilation too.)
case "${target_platform}" in
  osx-64)    keep=darwin-x64   ;;
  osx-arm64) keep=darwin-arm64 ;;
  *)         keep=             ;;  # linux: pi-tui has no native addon at all
esac
pi_tui="$(find "${PREFIX}" -type d -path '*@earendil-works/pi-tui' -print -quit)"
for d in "${pi_tui}"/native/*/prebuilds/*/; do
  [ -d "${d}" ] || continue
  [ "$(basename "${d}")" = "${keep}" ] || rm -rf "${d}"
done
# Prune now-empty OS / prebuilds directories left behind.
find "${pi_tui}/native" -depth -type d -empty -delete 2>/dev/null || true
