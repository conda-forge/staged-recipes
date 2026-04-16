#!/bin/bash
# Build script for presenton (Unix host — covers linux-64, linux-aarch64,
# osx-64, osx-arm64, and cross-compiled win-64 targets).
#
# Cross-compilation strategy for native Node.js binaries (@img/sharp):
#   npm ci always downloads binaries for the HOST platform.
#   pnpm's `supportedArchitectures` config overrides this — it downloads
#   binaries for any declared target even when running on a different OS/arch.
#   We patch package.json at build time to inject the correct target before
#   running `pnpm install`, so the standalone bundle always contains the right
#   platform-specific .node files regardless of the host machine.
set -euo pipefail

PRESENTON_SHARE="$PREFIX/share/presenton"
BACKEND_DST="$PRESENTON_SHARE/backend"
NEXTJS_DST="$PRESENTON_SHARE/nextjs"

# ---------------------------------------------------------------------------
# Step 1: Resolve target platform
# ---------------------------------------------------------------------------
# rattler-build sets $target_platform when cross-compiling (e.g. win-64 from
# linux-64). Fall back to $CONDA_SUBDIR or linux-64 if not set.
TARGET_PLATFORM="${target_platform:-${CONDA_SUBDIR:-linux-64}}"

case "${TARGET_PLATFORM}" in
  osx-64)        NPM_OS="darwin"; NPM_CPU="x64"   ;;
  osx-arm64)     NPM_OS="darwin"; NPM_CPU="arm64"  ;;
  win-64)        NPM_OS="win32";  NPM_CPU="x64"   ;;
  linux-aarch64) NPM_OS="linux";  NPM_CPU="arm64"  ;;
  *)             NPM_OS="linux";  NPM_CPU="x64"   ;;   # linux-64 default
esac

echo "==> Target platform : ${TARGET_PLATFORM}"
echo "==> pnpm target     : os=${NPM_OS}  cpu=${NPM_CPU}"

# ---------------------------------------------------------------------------
# Step 2: Build Next.js frontend
# ---------------------------------------------------------------------------
echo "==> Building Next.js frontend..."
cd "$SRC_DIR/servers/nextjs"

# Patch next.config.mjs to enable standalone output (self-contained Node server).
python3 - <<'PYEOF'
import re, sys
path = "next.config.mjs"
content = open(path).read()
if "output:" in content:
    print("next.config.mjs: 'output' already present, skipping patch")
    sys.exit(0)
content = re.sub(
    r'(const nextConfig\s*=\s*\{)',
    r'\1\n  output: "standalone",',
    content, count=1,
)
open(path, "w").write(content)
print("next.config.mjs: patched — added output: 'standalone'")
PYEOF

# Install pnpm globally (corepack is bundled with Node.js ≥16.9).
# pnpm's supportedArchitectures is the only reliable way to download
# platform-specific optional dependencies (e.g. @img/sharp-darwin-arm64)
# from a different host OS.
corepack enable
corepack prepare pnpm@10 --activate

# Patch package.json to declare the desired target architecture.
# pnpm reads pnpm.supportedArchitectures and downloads optional dependencies
# for *all* declared os/cpu combinations, regardless of the current host.
# libc: ["glibc", "unknown"] covers Linux (glibc) and macOS/Windows (no libc
# field in their packages — pnpm treats the absence as "unknown").
python3 - <<PYEOF
import json
path = "package.json"
pkg = json.load(open(path))
pkg.setdefault("pnpm", {})["supportedArchitectures"] = {
    "os":   ["${NPM_OS}"],
    "cpu":  ["${NPM_CPU}"],
    "libc": ["glibc", "unknown"],
}
json.dump(pkg, open(path, "w"), indent=2)
print("package.json: supportedArchitectures -> os=${NPM_OS} cpu=${NPM_CPU}")
PYEOF

# shamefully-hoist=true makes pnpm use the same flat node_modules layout as
# npm. Without it, pnpm's isolated store breaks TypeScript's transitive type
# lookups (e.g. @types/d3 referenced by recharts/mermaid), causing tsc errors
# during `next build`. This is written to a project-local .npmrc so it doesn't
# affect the user's global pnpm config.
echo "shamefully-hoist=true" >> .npmrc

# Install with pnpm.  --no-frozen-lockfile is required because we just mutated
# package.json (the existing package-lock.json is irrelevant for pnpm).
pnpm install --no-frozen-lockfile

# Build Next.js — produces .next-build/ with a standalone/ subdirectory.
pnpm run build

cd "$SRC_DIR"

# ---------------------------------------------------------------------------
# Step 3: Create installation directories
# ---------------------------------------------------------------------------
echo "==> Creating installation directories..."
mkdir -p "$BACKEND_DST"
mkdir -p "$NEXTJS_DST"

# ---------------------------------------------------------------------------
# Step 4: Copy Python backend
# ---------------------------------------------------------------------------
# The pyproject.toml has no [build-system], so the app must run from its
# source tree. We copy it and set PYTHONPATH in the launcher scripts.
echo "==> Copying Python backend..."
FASTAPI_SRC="$SRC_DIR/servers/fastapi"

for pkg in api enums models services constants utils; do
    [ -d "$FASTAPI_SRC/$pkg" ] && cp -r "$FASTAPI_SRC/$pkg" "$BACKEND_DST/"
done
cp "$FASTAPI_SRC/server.py" "$BACKEND_DST/"
for f in mcp_server.py migrations.py alembic.ini openai_spec.json; do
    [ -f "$FASTAPI_SRC/$f" ] && cp "$FASTAPI_SRC/$f" "$BACKEND_DST/" || true
done
[ -d "$FASTAPI_SRC/alembic" ] && cp -r "$FASTAPI_SRC/alembic" "$BACKEND_DST/" || true

# ---------------------------------------------------------------------------
# Step 5: Strip unused sharp variants, then copy Next.js frontend
# ---------------------------------------------------------------------------
echo "==> Copying Next.js frontend..."
NEXT_BUILD="$SRC_DIR/servers/nextjs/.next-build"
NEXTJS_SRC="$SRC_DIR/servers/nextjs"

if [ -d "$NEXT_BUILD/standalone" ]; then
    SHARP_MODS="$NEXT_BUILD/standalone/node_modules/@img"

    # pnpm only downloaded binaries for the target platform, so only that
    # platform's directories will exist. The rm -rf calls below are defensive
    # guards — they strip any stale or additional variants that might be present
    # (e.g. musl variants on glibc Linux, opposite-arch on macOS).
    case "${TARGET_PLATFORM}" in
      linux-64)
        rm -rf "${SHARP_MODS}/sharp-linuxmusl-x64"
        rm -rf "${SHARP_MODS}/sharp-libvips-linuxmusl-x64"
        ;;
      linux-aarch64)
        rm -rf "${SHARP_MODS}/sharp-linuxmusl-arm64"
        rm -rf "${SHARP_MODS}/sharp-libvips-linuxmusl-arm64"
        ;;
      osx-64)
        rm -rf "${SHARP_MODS}/sharp-darwin-arm64"
        rm -rf "${SHARP_MODS}/sharp-libvips-darwin-arm64"
        ;;
      osx-arm64)
        rm -rf "${SHARP_MODS}/sharp-darwin-x64"
        rm -rf "${SHARP_MODS}/sharp-libvips-darwin-x64"
        ;;
      win-64)
        # Windows ships a single x64 variant; nothing to strip.
        ;;
    esac

    cp -r "$NEXT_BUILD/standalone" "$NEXTJS_DST/"
    mkdir -p "$NEXTJS_DST/standalone/.next-build/static"
    cp -r "$NEXT_BUILD/static" "$NEXTJS_DST/standalone/.next-build/"
    [ -d "$NEXTJS_SRC/public" ] && cp -r "$NEXTJS_SRC/public" "$NEXTJS_DST/standalone/" || true
else
    echo "WARNING: standalone output not found; copying full build + node_modules"
    cp -r "$NEXT_BUILD" "$NEXTJS_DST/"
    cp -r "$NEXTJS_SRC/node_modules" "$NEXTJS_DST/"
    [ -d "$NEXTJS_SRC/public" ] && cp -r "$NEXTJS_SRC/public" "$NEXTJS_DST/" || true
    cp "$NEXTJS_SRC/package.json" "$NEXTJS_DST/"
fi

# ---------------------------------------------------------------------------
# Step 6: Create launcher scripts
# ---------------------------------------------------------------------------
echo "==> Creating launcher scripts..."

case "${TARGET_PLATFORM}" in
  win-64)
    # Cross-compiled Windows target: write .bat launchers from Linux.
    # build.bat handles the same when building natively on Windows.
    mkdir -p "$PREFIX/Scripts"

    cat > "$PREFIX/Scripts/presenton-backend.bat" << 'BAT'
@echo off
set PRESENTON_SHARE=%CONDA_PREFIX%\share\presenton
set PYTHONPATH=%PRESENTON_SHARE%\backend;%PYTHONPATH%
cd /d "%PRESENTON_SHARE%\backend"
if "%PRESENTON_PORT%"=="" set PRESENTON_PORT=8000
python server.py --port %PRESENTON_PORT% %*
BAT

    cat > "$PREFIX/Scripts/presenton-frontend.bat" << 'BAT'
@echo off
set PRESENTON_SHARE=%CONDA_PREFIX%\share\presenton
if "%PRESENTON_FRONTEND_PORT%"=="" set PRESENTON_FRONTEND_PORT=3000
if exist "%PRESENTON_SHARE%\nextjs\standalone" (
    cd /d "%PRESENTON_SHARE%\nextjs\standalone"
    set PORT=%PRESENTON_FRONTEND_PORT%
    node server.js
) else (
    cd /d "%PRESENTON_SHARE%\nextjs"
    set PORT=%PRESENTON_FRONTEND_PORT%
    npx next start
)
BAT

    cat > "$PREFIX/Scripts/presenton.bat" << 'BAT'
@echo off
if "%PRESENTON_PORT%"=="" set PRESENTON_PORT=8000
if "%PRESENTON_FRONTEND_PORT%"=="" set PRESENTON_FRONTEND_PORT=3000
echo Starting Presenton...
echo   API backend:  http://localhost:%PRESENTON_PORT%
echo   UI frontend:  http://localhost:%PRESENTON_FRONTEND_PORT%
start "" presenton-backend
timeout /t 2 /nobreak >nul
start "" presenton-frontend
BAT
    ;;

  *)
    # Unix launchers (linux-64, linux-aarch64, osx-64, osx-arm64)
    mkdir -p "$PREFIX/bin"

    cat > "$PREFIX/bin/presenton-backend" << 'SCRIPT'
#!/bin/bash
# Presenton FastAPI backend launcher
PRESENTON_SHARE="${CONDA_PREFIX:-${PREFIX}}/share/presenton"
export PYTHONPATH="${PRESENTON_SHARE}/backend${PYTHONPATH:+:${PYTHONPATH}}"
cd "${PRESENTON_SHARE}/backend"
exec python server.py --port "${PRESENTON_PORT:-8000}" "$@"
SCRIPT
    chmod +x "$PREFIX/bin/presenton-backend"

    cat > "$PREFIX/bin/presenton-frontend" << 'SCRIPT'
#!/bin/bash
# Presenton Next.js frontend launcher
PRESENTON_SHARE="${CONDA_PREFIX:-${PREFIX}}/share/presenton"
STANDALONE="${PRESENTON_SHARE}/nextjs/standalone"
if [ -d "${STANDALONE}" ]; then
    cd "${STANDALONE}"
    HOSTNAME=0.0.0.0 PORT="${PRESENTON_FRONTEND_PORT:-3000}" exec node server.js
else
    cd "${PRESENTON_SHARE}/nextjs"
    PORT="${PRESENTON_FRONTEND_PORT:-3000}" exec npx next start
fi
SCRIPT
    chmod +x "$PREFIX/bin/presenton-frontend"

    cat > "$PREFIX/bin/presenton" << 'SCRIPT'
#!/bin/bash
# Presenton — start both backend and frontend
BACKEND_PORT="${PRESENTON_PORT:-8000}"
FRONTEND_PORT="${PRESENTON_FRONTEND_PORT:-3000}"
echo "Starting Presenton..."
echo "  API backend:  http://localhost:${BACKEND_PORT}"
echo "  UI frontend:  http://localhost:${FRONTEND_PORT}"
echo "Press Ctrl+C to stop all servers."
echo ""
presenton-backend &
BACKEND_PID=$!
sleep 2
presenton-frontend &
FRONTEND_PID=$!
trap 'echo "Stopping..."; kill ${BACKEND_PID} ${FRONTEND_PID} 2>/dev/null; wait; exit 0' INT TERM
wait ${BACKEND_PID} ${FRONTEND_PID}
SCRIPT
    chmod +x "$PREFIX/bin/presenton"
    ;;
esac

echo "==> presenton installation complete."
