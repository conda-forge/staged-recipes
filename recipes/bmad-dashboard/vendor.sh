#!/bin/bash
# Generate the vendored pnpm store tarball for the bmad-dashboard conda recipe.
#
# Run on any host with node >=22, pnpm >=10, and tar.
# Steps:
#   1. Download and extract the upstream source tarball pinned in recipe.yaml.
#   2. From inside the extracted source tree, run this script:
#        bash /path/to/recipes/bmad-dashboard/vendor.sh 1.3.0
#   3. Upload the resulting tarball to a stable HTTPS host
#      (e.g. a release on github.com/rxm7706/conda-recipes-vendored).
#   4. Paste the printed sha256 value into recipe.yaml's source[1] entry,
#      and update the URL if you used a different host.
set -euxo pipefail

VERSION="${1:?usage: vendor.sh <bmad-dashboard-version, e.g. 1.3.0>}"
WORK="$(pwd)"

[[ -f package.json && -f pnpm-lock.yaml ]] || {
  echo "ERROR: run this script from the extracted bmad-dashboard-extension source tree." >&2
  exit 1
}

# pnpm fetch: populates a portable content-addressable store with every
# tarball referenced in pnpm-lock.yaml. Only stores files; no symlinks
# are created, so the resulting tarball is fully relocatable.
mkdir -p "${WORK}/pnpm-store"
pnpm fetch --frozen-lockfile --store-dir "${WORK}/pnpm-store"

# Tar without a top-level wrapper directory so the recipe can use
# `target_directory:` to pick the extraction location.
( cd "${WORK}/pnpm-store" && tar -czf "${WORK}/bmad-dashboard-pnpm-store-${VERSION}.tar.gz" . )

echo
echo "=== sha256 value for recipe.yaml ==="
shasum -a 256 "bmad-dashboard-pnpm-store-${VERSION}.tar.gz"
echo
echo "Upload the tarball to a stable HTTPS host, then update"
echo "recipes/bmad-dashboard/recipe.yaml source[1].sha256."
