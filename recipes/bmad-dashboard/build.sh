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

if command -v corepack >/dev/null 2>&1; then
    echo ">> activating pnpm ${PNPM_VERSION} via corepack"
    export COREPACK_HOME="${BUILD_PREFIX:-$PREFIX}/corepack"
    mkdir -p "${COREPACK_HOME}"
    corepack enable --install-directory "${BUILD_PREFIX:-$PREFIX}/bin"
    corepack prepare "pnpm@${PNPM_VERSION}" --activate
else
    echo ">> corepack not found, installing pnpm via npm"
    npm install -g "pnpm@${PNPM_VERSION}"
fi

echo "    pnpm:  $(pnpm --version)"

echo ">> fetching node dependencies"
pnpm install --frozen-lockfile

echo ">> building extension + webview"
pnpm build

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
