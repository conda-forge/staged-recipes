#!/usr/bin/env bash
# Build the BMAD Dashboard VS Code extension as a conda package.
#
# Strategy:
#   1. Provision pnpm 10.26.2 (upstream's pinned packageManager) via corepack,
#      with `npm install -g pnpm@10.26.2` as a fallback.
#   2. `pnpm install --frozen-lockfile && pnpm build` compiles the extension.
#   3. node_modules is removed so vsce's secret scanner cannot flag tokens
#      in devDependencies (e.g. semantic-release, @octokit packages).
#      vscode:prepublish is overridden to a no-op before this removal.
#   4. `vsce package --no-dependencies` produces out/bmad-method-ui-1.2.2.vsix.
#   5. Layer a small Python wrapper around the .vsix that exposes a
#      `bmad-dashboard-install` CLI entry point. The wrapper sources live
#      under $RECIPE_DIR/wrapper/.
#   6. Pip-install the wrapper so conda-build picks up the entry point.
set -euo pipefail

echo ">> environment"
echo "    node:  $(node --version)"
echo "    npm:   $(npm --version)"

# Keep package-manager caches OUT of $SRC_DIR so vsce doesn't vacuum them
# into the .vsix. Also keep pnpm itself here so it doesn't land in $PREFIX
# and get packaged into the conda output (rattler-build rejects symlinks).
# CACHE_ROOT must be defined before pnpm is installed.
CACHE_ROOT="$(dirname "${SRC_DIR}")/_pkg_caches"
mkdir -p "${CACHE_ROOT}/npm" "${CACHE_ROOT}/pnpm-cli" "${CACHE_ROOT}/corepack" \
         "${CACHE_ROOT}/pnpm-store" "${CACHE_ROOT}/pnpm-state" \
         "${CACHE_ROOT}/xdg_data"

PNPM_VERSION="10.26.2"

if command -v corepack >/dev/null 2>&1; then
    echo ">> activating pnpm ${PNPM_VERSION} via corepack"
    export COREPACK_HOME="${CACHE_ROOT}/corepack"
    corepack enable --install-directory "${CACHE_ROOT}/pnpm-cli"
    corepack prepare "pnpm@${PNPM_VERSION}" --activate
    export PATH="${CACHE_ROOT}/pnpm-cli:${PATH}"
else
    echo ">> corepack not found, installing pnpm via npm"
    # Install to CACHE_ROOT/pnpm-cli, NOT to $PREFIX, so pnpm files don't end
    # up in the conda package output. rattler-build rejects packages that
    # contain symlinks (npm's global install creates python-scripts/pnpm ->
    # ../lib/node_modules/pnpm/... on Linux, which trips the symlink check).
    npm install -g --prefix "${CACHE_ROOT}/pnpm-cli" "pnpm@${PNPM_VERSION}"
    export PATH="${CACHE_ROOT}/pnpm-cli/bin:${PATH}"
fi

echo "    pnpm:  $(pnpm --version)"

# XDG_DATA_HOME controls where pnpm puts its store (default ~/.local/share).
# Relocating it here keeps the store on the same filesystem as $SRC_DIR so
# pnpm can use hardlinks instead of symlinks, avoiding vsce scanning the
# global store through dangling symlinks in node_modules/.pnpm.
# XDG_STATE_HOME keeps pnpm's state files out of ~/.local/state.
export npm_config_cache="${CACHE_ROOT}/npm"
export XDG_DATA_HOME="${CACHE_ROOT}/xdg_data"
export XDG_STATE_HOME="${CACHE_ROOT}/pnpm-state"

echo ">> fetching node dependencies"
pnpm install --frozen-lockfile

# Rebrand package.json before any build step bakes the identity in.
# Upstream's package.json at the pinned commit still self-IDs as
# elvince/bmad-dashboard-extension, but bmad-code-org/bmad-method-ui is the
# canonical home. Rewrite both the marketplace metadata fields and the
# user-visible UI labels in contributes so VS Code shows the bmad-method-ui
# identity everywhere (extension card, sidebar title, command palette).
#
# vscode:prepublish is replaced with a no-op because we run `pnpm build`
# explicitly below; this prevents vsce from re-running it after node_modules
# has been removed (see the "remove node_modules" step before packaging).
echo ">> rebranding package.json -> bmad-code-org.bmad-method-ui"
"${PYTHON}" - <<'PY'
import json, pathlib
p = pathlib.Path("package.json")
pj = json.loads(p.read_text(encoding="utf-8"))

# Marketplace identity
pj["name"] = "bmad-method-ui"
pj["publisher"] = "bmad-code-org"
pj["displayName"] = "BMad Method UI"
pj["description"] = "Interactive dashboard for BMad Method V6 projects"
pj["repository"] = {
    "type": "git",
    "url": "https://github.com/bmad-code-org/bmad-method-ui.git",
}
pj["homepage"] = "https://github.com/bmad-code-org/bmad-method-ui#readme"
pj["bugs"] = {"url": "https://github.com/bmad-code-org/bmad-method-ui/issues"}

# User-visible labels (sidebar header, command palette)
contributes = pj.get("contributes", {})
for vc in contributes.get("viewsContainers", {}).get("activitybar", []):
    if vc.get("title") == "BMAD Dashboard":
        vc["title"] = "BMad Method UI"
for cmd in contributes.get("commands", []):
    title = cmd.get("title", "")
    if title.startswith("BMAD:"):
        cmd["title"] = "BMad:" + title[len("BMAD:"):]

# Replace vscode:prepublish with a no-op so vsce does not re-run the full
# build after node_modules is removed for the secret-scan workaround below.
pj.setdefault("scripts", {})["vscode:prepublish"] = \
    "echo 'Pre-build completed by conda recipe build.sh'"

p.write_text(json.dumps(pj, indent=2) + "\n", encoding="utf-8")
PY

echo ">> building extension + webview"
pnpm build

# Defense in depth: vsce walks $SRC_DIR and ships everything not in
# .vscodeignore. rattler-build writes its own wrapper scripts directly into
# $SRC_DIR (build_env.{sh,bat}, conda_build.{sh,bat}, conda_build.log) so
# even with caches relocated, those files would still ride along.
echo ">> appending conda-build excludes to .vscodeignore"
cat >> .vscodeignore <<'EOF'

# Excluded by conda-forge recipe build.sh
node_modules/**
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

# vsce's secret scanner walks the entire workspace for token patterns, even
# files that are excluded by .vscodeignore.  devDependencies such as
# semantic-release and @octokit contain GitHub token examples that trigger
# false positives.  Remove node_modules before packaging so the scanner sees
# only the compiled output in out/.
# vscode:prepublish was already replaced with a no-op above so vsce won't try
# to rebuild after node_modules is gone.
echo ">> removing node_modules to prevent vsce false-positive secret scan"
rm -rf node_modules

# @vscode/vsce is not a devDependency; the vscode:package script invokes it
# via npx (on-demand download). We call it the same way here so there is no
# version to pin from node_modules.
echo ">> packaging .vsix"
npx --yes @vscode/vsce package --no-dependencies -o out/

VSIX_SRC=$(ls out/*.vsix | head -n 1)
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
