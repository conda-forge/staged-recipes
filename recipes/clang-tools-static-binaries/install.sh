#!/usr/bin/env bash
# install.sh – conda-build install script for a single clang-tools version (Unix)
#
# Environment variables (set by meta.yaml):
#   RELEASE_TAG    GitHub release tag (e.g. 2026.06.04-14db129d)
#   CLANG_VERSION  Clang major version (e.g. 20)
#   PREFIX         Conda install prefix
#
# Platform detection:
#   The script translates conda's target_platform into the upstream suffix
#   used in binary names (e.g. linux-amd64, macos-arm64).
set -euo pipefail

RELEASE_URL="https://github.com/cpp-linter/clang-tools-static-binaries/releases/download/${RELEASE_TAG}"
TOOLS=("clang-format" "clang-tidy" "clang-query" "clang-apply-replacements")

# ------------------------------------------------------------------
# 1. Map conda target_platform → upstream binary suffix
# ------------------------------------------------------------------
case "${target_platform:-}" in
    linux-64)       SUFFIX="${CLANG_VERSION}_linux-amd64" ;;
    linux-aarch64)  SUFFIX="${CLANG_VERSION}_linux-arm64" ;;
    osx-64)         SUFFIX="${CLANG_VERSION}_macos-amd64" ;;
    osx-arm64)      SUFFIX="${CLANG_VERSION}_macos-arm64" ;;
    *)
        echo "ERROR: unknown target_platform '${target_platform:-}'" >&2
        exit 1
        ;;
esac

echo "RELEASE_TAG  = ${RELEASE_TAG}"
echo "CLANG_VERSION = ${CLANG_VERSION}"
echo "SUFFIX        = ${SUFFIX}"
echo "PREFIX        = ${PREFIX}"

mkdir -p "${PREFIX}/bin"

# ------------------------------------------------------------------
# 2. Download, verify, and install each tool
# ------------------------------------------------------------------
for tool in "${TOOLS[@]}"; do
    binary_name="${tool}-${SUFFIX}"
    checksum_name="${binary_name}.sha512sum"
    dest="${PREFIX}/bin/${tool}-${CLANG_VERSION}"

    echo ""
    echo "--- ${tool} ---"

    # Download binary
    echo "  Downloading ${binary_name} ..."
    curl -fSL --retry 3 --retry-delay 10 \
        -o "${dest}" \
        "${RELEASE_URL}/${binary_name}"

    # Download checksum
    echo "  Downloading ${checksum_name} ..."
    curl -fSL --retry 3 --retry-delay 10 \
        -o /tmp/conda-clang-tools.sha512 \
        "${RELEASE_URL}/${checksum_name}"

    # Verify
    echo "  Verifying SHA-512 ..."
    EXPECTED=$(awk '{print $1}' /tmp/conda-clang-tools.sha512)
    # macOS uses 'shasum -a 512', Linux uses 'sha512sum'
    if command -v sha512sum &>/dev/null; then
        ACTUAL=$(sha512sum "${dest}" | awk '{print $1}')
    else
        ACTUAL=$(shasum -a 512 "${dest}" | awk '{print $1}')
    fi
    if [[ "${EXPECTED}" != "${ACTUAL}" ]]; then
        echo "ERROR: SHA-512 mismatch for ${binary_name}" >&2
        echo "  expected: ${EXPECTED}" >&2
        echo "  got:      ${ACTUAL}" >&2
        exit 1
    fi
    echo "  SHA-512 OK"

    # Make executable
    chmod +x "${dest}"

    echo "  Installed ${dest}"
    rm -f /tmp/conda-clang-tools.sha512
done

# ------------------------------------------------------------------
# 3. Install versions.json for reference (best-effort)
# ------------------------------------------------------------------
mkdir -p "${PREFIX}/share/clang-tools-static"
echo ""
echo "--- versions.json (best-effort) ---"
curl -fSL --retry 2 --retry-delay 5 \
    -o "${PREFIX}/share/clang-tools-static/versions.json" \
    "${RELEASE_URL}/versions.json" 2>/dev/null || \
    echo "  (versions.json not available in this release — will be present in future releases)"

echo ""
echo "Installation complete."
ls -la "${PREFIX}/bin/"
