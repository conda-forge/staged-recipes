#!/bin/bash
set -ex

# Enable CGO for SQLite support
export CGO_ENABLED=1

# Set Go build flags
export GOFLAGS="-buildmode=pie -trimpath -mod=readonly -modcacherw"

# Version from conda build (or rattler-build)
VERSION="${PKG_VERSION}"

# Remember source directory (handle both conda-build and rattler-build)
if [ -n "${SRC_DIR}" ]; then
    SRC_ROOT="${SRC_DIR}"
else
    SRC_ROOT="$(pwd)"
fi

# Debug info
echo "=== Build environment ==="
echo "SRC_ROOT: ${SRC_ROOT}"
echo "PREFIX: ${PREFIX}"
echo "PWD: $(pwd)"

# Collect licenses from Go dependencies
# Remove existing directory first to avoid "already exists" error
rm -rf "${SRC_ROOT}/library_licenses"
mkdir -p "${SRC_ROOT}/library_licenses"

echo "=== Collecting dependency licenses with go-licenses ==="
# go-licenses may fail for some packages, so we continue on error
# but we still want the licenses it can find
go-licenses save ./... \
    --save_path="${SRC_ROOT}/library_licenses" \
    --ignore=github.com/writefreely/writefreely || {
    echo "WARNING: go-licenses had some issues, but continuing..."
}

# If library_licenses is empty, create a placeholder
if [ -z "$(ls -A ${SRC_ROOT}/library_licenses 2>/dev/null)" ]; then
    echo "No third-party licenses were collected" > "${SRC_ROOT}/library_licenses/README.txt"
fi

echo "Collected licenses:"
ls -la "${SRC_ROOT}/library_licenses/" || true

# Build the writefreely binary with SQLite and netgo support
# - 'sqlite' tag enables SQLite database support (requires CGO)
# - 'netgo' tag uses pure Go network implementations
echo "=== Building WriteFreely ==="
cd "${SRC_ROOT}/cmd/writefreely"
go build -v \
    -tags='netgo sqlite' \
    -ldflags="-s -w -X 'github.com/writefreely/writefreely.softwareVer=${VERSION}'" \
    -o "${PREFIX}/bin/writefreely" \
    .

# Return to source root (IMPORTANT for license file detection)
cd "${SRC_ROOT}"

# Copy static assets and templates that WriteFreely needs at runtime
echo "=== Copying static assets ==="
mkdir -p "${PREFIX}/share/writefreely"
cp -r pages "${PREFIX}/share/writefreely/" 2>/dev/null || true
cp -r templates "${PREFIX}/share/writefreely/" 2>/dev/null || true
cp -r static "${PREFIX}/share/writefreely/" 2>/dev/null || true
cp -r keys "${PREFIX}/share/writefreely/" 2>/dev/null || true
cp schema.sql "${PREFIX}/share/writefreely/" 2>/dev/null || true
cp sqlite.sql "${PREFIX}/share/writefreely/" 2>/dev/null || true

echo "=== Build completed successfully! ==="
echo "Final PWD: $(pwd)"
echo "LICENSE file: $(ls -la ${SRC_ROOT}/LICENSE)"
echo "library_licenses: $(ls ${SRC_ROOT}/library_licenses/ | wc -l) directories"
