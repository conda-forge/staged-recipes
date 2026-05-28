#!/usr/bin/env bash
# Build the BMAD Dashboard VS Code extension as a conda package.
#
# Strategy:
#   1. Provision pnpm 10.26.2 (upstream's pinned packageManager) via corepack,
#      with `npm install -g pnpm@10.26.2` as a fallback.
#   2. `pnpm install --frozen-lockfile && pnpm build && pnpm vscode:package`
#      produces out/bmad-dashboard-1.2.2.vsix.
#   3. Layer a small Python wrapper around the .vsix that exposes a
#      `bmad-dashboard-install` CLI entry point. The wrapper sources live
#      under $RECIPE_DIR/wrapper/.
#   4. Pip-install the wrapper so conda-build picks up the entry point.
set -euo pipefail

echo ">> environment"
echo "    node:  $(node --version)"
echo "    npm:   $(npm --version)"

PNPM_VERSION="10.26.2"

# rattler-build on Windows can leak BUILD_PREFIX into bash as the literal
# CMD placeholder `%BUILD_PREFIX%`. Treat that (and a plain-empty value) as
# unset and fall back to $PREFIX.
case "${BUILD_PREFIX:-}" in
    ""|*%*) BP="${PREFIX}" ;;
    *)      BP="${BUILD_PREFIX}" ;;
esac

# conda's Windows layout puts shims under Library/bin; *nix uses bin.
if [[ -d "${BP}/Library/bin" ]]; then
    BP_BIN="${BP}/Library/bin"
else
    BP_BIN="${BP}/bin"
fi

if command -v corepack >/dev/null 2>&1; then
    echo ">> activating pnpm ${PNPM_VERSION} via corepack"
    export COREPACK_HOME="${BP}/corepack"
    mkdir -p "${COREPACK_HOME}" "${BP_BIN}"
    corepack enable --install-directory "${BP_BIN}"
    corepack prepare "pnpm@${PNPM_VERSION}" --activate
else
    echo ">> corepack not found, installing pnpm via npm"
    npm install -g "pnpm@${PNPM_VERSION}"
fi

echo "    pnpm:  $(pnpm --version)"

# Keep package-manager caches OUT of $SRC_DIR so vsce doesn't vacuum them
# into the .vsix. conda-forge nodejs activation seeds npm/pnpm caches under
# $SRC_DIR for hermeticity (npm-cache/, .pnpm/, .pnpm-cache/, .pnpm-state/),
# which adds ~400 MB of garbage to the .vsix. Park them next to $SRC_DIR
# instead — still inside the per-build sandbox, so they're cleaned up with
# the rest of the build.
CACHE_ROOT="$(dirname "${SRC_DIR}")/_pkg_caches"
mkdir -p "${CACHE_ROOT}/npm" "${CACHE_ROOT}/pnpm-store" "${CACHE_ROOT}/pnpm-state"
export npm_config_cache="${CACHE_ROOT}/npm"
export PNPM_STORE_PATH="${CACHE_ROOT}/pnpm-store"
export XDG_STATE_HOME="${CACHE_ROOT}/pnpm-state"

echo ">> fetching node dependencies"
pnpm install --frozen-lockfile

echo ">> building extension + webview"
pnpm build

# Defense in depth: vsce walks $SRC_DIR and ships everything not in
# .vscodeignore. rattler-build writes its own wrapper scripts directly into
# $SRC_DIR (build_env.{sh,bat}, conda_build.{sh,bat}, conda_build.log) so
# even with caches relocated, those files would still ride along.
echo ">> appending conda-build excludes to .vscodeignore"
cat >> .vscodeignore <<'EOF'

# Excluded by conda-forge recipe build.sh
.pnpm/**
.pnpm-cache/**
.pnpm-state/**
npm-cache/**
build_env.sh
build_env.bat
conda_build.sh
conda_build.bat
conda_build.log
_pkg_caches/**
_pywrap/**
EOF

echo ">> packaging .vsix"
pnpm vscode:package

VSIX_SRC=$(ls out/bmad-dashboard-*.vsix | head -n 1)
test -f "${VSIX_SRC}" || { echo "ERROR: no .vsix produced under out/"; exit 1; }
VSIX_NAME=$(basename "${VSIX_SRC}")
echo "    built: ${VSIX_NAME}"

echo ">> staging Python wrapper"
WRAP="${SRC_DIR}/_pywrap"
rm -rf "${WRAP}"
mkdir -p "${WRAP}"
cp -r "${RECIPE_DIR}/wrapper/." "${WRAP}/"
mkdir -p "${WRAP}/src/bmad_dashboard/data"
cp "${VSIX_SRC}" "${WRAP}/src/bmad_dashboard/data/${VSIX_NAME}"
cp "${SRC_DIR}/LICENSE.md" "${WRAP}/LICENSE"

echo ">> pip install wrapper"
cd "${WRAP}"
${PYTHON} -m pip install . --no-deps --no-build-isolation -vv

echo ">> done"
