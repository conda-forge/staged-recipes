#!/usr/bin/env bash
# Build the MyBMAD Dashboard (web/) as a conda package.
#
# Strategy (mirrors recipes/bmad-dashboard/build.sh, adapted for a Next.js
# server app instead of a VS Code extension):
#   1. Provision pnpm (upstream's package manager) via corepack, keeping all
#      caches OUT of $SRC_DIR and $PREFIX.
#   2. `pnpm install` + `prisma generate` + `next build` in web/ to produce the
#      Next.js `standalone` server bundle (web/.next/standalone/server.js).
#   3. Assemble a self-contained, symlink-free runner directory: the (possibly
#      nested) standalone app root + static + public + the generated Prisma
#      client/engine + the migration SQL files. Migrations are applied at
#      runtime with psql, so the Prisma CLI is NOT shipped.
#   4. Stage that runner dir as package-data inside a small Python wrapper that
#      exposes the `mybmad` launcher CLI (wrapper sources live under
#      $RECIPE_DIR/wrapper/).
#   5. Pip-install the wrapper so conda-build picks up the entry point.
#
# NOTE: the upstream source is NOT patched. All conda-specific behavior lives
# in the wrapper. This keeps the recipe faithful to upstream across bumps.
set -euo pipefail

echo ">> environment"
echo "    node:  $(node --version)"
echo "    npm:   $(npm --version)"

# The web app is a subdirectory of the repo archive.
WEB_DIR="${SRC_DIR}/web"
test -d "${WEB_DIR}" || { echo "ERROR: ${WEB_DIR} not found in source archive"; exit 1; }

# Keep package-manager caches OUT of $SRC_DIR (so they don't get packaged) and
# OUT of $PREFIX (rattler-build rejects stray symlinks).
CACHE_ROOT="$(dirname "${SRC_DIR}")/_pkg_caches"
mkdir -p "${CACHE_ROOT}/npm" "${CACHE_ROOT}/pnpm-cli" "${CACHE_ROOT}/corepack" \
         "${CACHE_ROOT}/pnpm-store" "${CACHE_ROOT}/pnpm-state" \
         "${CACHE_ROOT}/xdg_data"

# pnpm version: prefer the `packageManager` field in web/package.json; fall back
# to a known-good pin. (Upstream web/ pins pnpm via packageManager / lockfile.)
PNPM_VERSION="$("${PYTHON}" - "${WEB_DIR}/package.json" <<'PY'
import json, sys
pj = json.load(open(sys.argv[1]))
pm = pj.get("packageManager", "")
# format: "pnpm@10.28.1" -> 10.28.1 ; default if absent
print(pm.split("@", 1)[1] if pm.startswith("pnpm@") else "10.28.1")
PY
)"
echo ">> pnpm version: ${PNPM_VERSION}"

if command -v corepack >/dev/null 2>&1; then
    echo ">> activating pnpm ${PNPM_VERSION} via corepack"
    export COREPACK_HOME="${CACHE_ROOT}/corepack"
    corepack enable --install-directory "${CACHE_ROOT}/pnpm-cli"
    corepack prepare "pnpm@${PNPM_VERSION}" --activate
    export PATH="${CACHE_ROOT}/pnpm-cli:${PATH}"
else
    echo ">> corepack not found, installing pnpm via npm"
    npm install -g --prefix "${CACHE_ROOT}/pnpm-cli" "pnpm@${PNPM_VERSION}"
    export PATH="${CACHE_ROOT}/pnpm-cli/bin:${PATH}"
fi
echo "    pnpm:  $(pnpm --version)"

# Relocate pnpm store/state onto the same filesystem as $SRC_DIR.
export npm_config_cache="${CACHE_ROOT}/npm"
export XDG_DATA_HOME="${CACHE_ROOT}/xdg_data"
export XDG_STATE_HOME="${CACHE_ROOT}/pnpm-state"

cd "${WEB_DIR}"

# Force a FLAT (hoisted) node_modules. pnpm's default "isolated" linker builds
# a symlink farm (node_modules/<pkg> -> .pnpm/...), which Next.js preserves as
# symlinks in the standalone bundle. Those break two ways: rattler-build
# rejects packages containing symlinks, and naively dereferencing them loses
# pnpm's sibling-resolution topology (next can't find styled-jsx, etc.). The
# hoisted linker lays out real, npm-style top-level packages -> the standalone
# bundle is symlink-free and relocatable.
export npm_config_node_linker=hoisted

echo ">> installing node dependencies (web/, hoisted node-linker)"
pnpm install --frozen-lockfile --node-linker=hoisted

# `prisma generate` needs SOME DATABASE_URL even though it doesn't connect.
# web/prisma.config.ts already supplies a placeholder for the `generate`
# command, but export one anyway to be safe across prisma versions.
export DATABASE_URL="postgresql://placeholder:placeholder@localhost:5432/placeholder"
export BETTER_AUTH_SECRET="build-time-placeholder-not-used-at-runtime"
export BETTER_AUTH_URL="http://localhost:3002"

echo ">> generating Prisma client"
pnpm db:generate

echo ">> building Next.js standalone bundle"
pnpm build

# Locate server.js dynamically. Next.js infers the workspace root by walking up
# for lockfiles; because the repo root carries its own pnpm-lock.yaml (the VS
# Code extension), Next selects $SRC_DIR as the root and NESTS the standalone
# output under .next/standalone/web/server.js (rather than .../server.js). This
# detection handles both the nested and flat layouts.
SERVER_JS="$(find .next/standalone -maxdepth 4 -name server.js | head -1)"
test -n "${SERVER_JS}" || {
  echo "ERROR: no server.js under .next/standalone. Is output:'standalone' set?";
  exit 1; }
APPSRC="$(dirname "${SERVER_JS}")"
echo "    standalone app root: ${APPSRC}"

echo ">> staging Python wrapper"
WRAP="${SRC_DIR}/_pywrap"
rm -rf "${WRAP}"
mkdir -p "${WRAP}"
cp -r "${RECIPE_DIR}/wrapper/." "${WRAP}/"
cp "${WEB_DIR}/LICENSE" "${WRAP}/LICENSE"

# ---------------------------------------------------------------------------
# Assemble the runner dir, mirroring upstream Dockerfile's `runner` stage.
# ---------------------------------------------------------------------------
APP="${WRAP}/src/mybmad_dashboard/app"
rm -rf "${APP}"
mkdir -p "${APP}"

echo ">> assembling standalone runner into ${APP}"
# rattler-build rejects packages containing symlinks. The hoisted build leaves
# exactly one relative symlink in the standalone tree: the Prisma client alias
#   .next/node_modules/@prisma/client-<hash> -> ../../../../web/node_modules/@prisma/client
# The turbopack server runtime imports this alias to load the Prisma engine, so
# it MUST survive. Its relative target only resolves in place, so dereference it
# HERE — before the flatten move below — otherwise the move breaks the target
# and the alias would be dropped, breaking every DB query at runtime. Genuinely
# dangling links (none expected with the hoisted linker) are removed.
find "${APPSRC}" -type l | while IFS= read -r link; do
  if [ -e "${link}" ]; then
    cp -RL "${link}" "${link}.deref" && rm "${link}" && mv "${link}.deref" "${link}"
  else
    rm -f "${link}"
  fi
done

# Flatten: the standalone app root (APPSRC, possibly .../standalone/web) becomes
# the package's app root, so the launcher always finds app/server.js. With the
# hoisted node-linker the traced node_modules are real files, so a plain copy
# preserves runtime module resolution.
# 1. standalone server (server.js + real node_modules + .next/server)
cp -R "${APPSRC}/." "${APP}/"
# 2. static assets and public (not traced into standalone)
mkdir -p "${APP}/.next"
cp -R .next/static "${APP}/.next/static"
[ -d public ] && cp -R public "${APP}/public"
# 3. generated Prisma client + native query engine (Dockerfile copies this
#    explicitly; the custom output path src/generated/prisma — including
#    libquery_engine-<platform>.node — is what makes this package arch-specific).
mkdir -p "${APP}/src"
rm -rf "${APP}/src/generated"
cp -R src/generated "${APP}/src/generated"
# 4. Migration SQL only. The launcher applies these with psql at runtime via a
#    small tracking table, so the Prisma CLI/engines are NOT shipped (they live
#    behind pnpm symlinks and aren't needed once migrations are plain SQL).
mkdir -p "${APP}/prisma"
cp -R prisma/migrations "${APP}/prisma/migrations"

# Assert the assembled tree is symlink-free (symlinks were dereferenced at the
# source above). rattler-build rejects packages containing symlinks.
REMAINING_LINKS="$(find "${APP}" -type l | wc -l | tr -d ' ')"
test "${REMAINING_LINKS}" = "0" || {
  echo "ERROR: ${REMAINING_LINKS} symlink(s) remain in ${APP}"; exit 1; }

echo ">> pip install wrapper"
cd "${WRAP}"
${PYTHON} -m pip install . --no-deps --no-build-isolation -vv

echo ">> done"
