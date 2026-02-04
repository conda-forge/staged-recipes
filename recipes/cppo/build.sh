#!/usr/bin/env bash
set -euxo pipefail

# ==============================================================================
# CPPO BUILD SCRIPT (Standalone Recipe)
# ==============================================================================
# Build the cppo preprocessor for OCaml using Dune.
# Standalone version - source extracts to ${SRC_DIR} directly.
#
# CRITICAL: cppo is a BUILD-TIME tool that runs on the BUILD machine.
# In cross-compilation scenarios, cppo MUST be built for BUILD arch.
# ==============================================================================

source "${RECIPE_DIR}/building/build_functions.sh"

# ==============================================================================
# ENVIRONMENT SETUP
# ==============================================================================

cd "${SRC_DIR}"

# macOS: OCaml compiler has @rpath/libzstd.1.dylib embedded but rpath doesn't
# resolve in build environment. Set DYLD_FALLBACK_LIBRARY_PATH so executables
# can find libzstd at runtime.
if is_macos; then
  export DYLD_FALLBACK_LIBRARY_PATH="${BUILD_PREFIX}/lib:${PREFIX}/lib:${DYLD_FALLBACK_LIBRARY_PATH:-}"
fi

# Windows: Set install prefix and ensure OCaml binaries are in PATH
if is_non_unix; then
  export CPPO_INSTALL_PREFIX="${_PREFIX_}/Library"
  export PATH="${BUILD_PREFIX}/bin:${BUILD_PREFIX}/Library/bin:${PATH}"

  echo "=== Windows build environment ==="
  echo "Install prefix: ${CPPO_INSTALL_PREFIX}"
  echo "PATH: ${PATH}"
else
  export CPPO_INSTALL_PREFIX="${PREFIX}"
fi

# Set OCAMLPATH so dune can find ocamlbuild package (META in lib/ocaml/ocamlbuild/)
if is_non_unix; then
  export OCAMLPATH="${BUILD_PREFIX}/Library/lib/ocaml:${OCAMLPATH:-}"
else
  export OCAMLPATH="${BUILD_PREFIX}/lib/ocaml:${OCAMLPATH:-}"
fi

# ==============================================================================
# PACKAGE SELECTION
# ==============================================================================
# BUILD_CPPO_OCAMLBUILD is set by recipe.yaml based on ocamlbuild availability
# cppo_ocamlbuild requires ocamlbuild >= 0.16.1 build 1

if [[ "${BUILD_CPPO_OCAMLBUILD:-0}" == "1" ]]; then
  DUNE_PACKAGES="cppo,cppo_ocamlbuild"
else
  DUNE_PACKAGES="cppo"
fi

echo "=== Build configuration ==="
echo "  BUILD_CPPO_OCAMLBUILD: ${BUILD_CPPO_OCAMLBUILD:-0}"
echo "  DUNE_PACKAGES: ${DUNE_PACKAGES}"

# ==============================================================================
# PLATFORM-SPECIFIC BUILD
# ==============================================================================

# Debug: Show cross-compilation environment
echo "=== Cross-compilation detection ==="
echo "  CONDA_BUILD_CROSS_COMPILATION: ${CONDA_BUILD_CROSS_COMPILATION:-not set}"
echo "  build_platform: ${build_platform:-not set}"
echo "  target_platform: ${target_platform:-not set}"
echo "  is_cross_compile: $(is_cross_compile && echo 'true' || echo 'false')"

if is_cross_compile; then
  # ===========================================================================
  # CROSS-COMPILATION PATH
  # ===========================================================================
  echo "=== Cross-compilation build ==="
  echo "CRITICAL: cppo is a BUILD-TIME tool - building for BUILD arch (${build_platform})"

  # cppo runs on BUILD machine to preprocess source files
  # It does NOT need to be cross-compiled to TARGET arch

  # Ensure we use BUILD compiler (not cross-compiler)
  # The native OCaml compiler should already be in PATH from build deps

  echo "Using native OCaml compiler for cppo (BUILD arch)..."
  echo "  ocamlc: $(which ocamlc)"
  ocamlc -version

  # Verify it's native arch (not cross-arch)
  DETECTED_ARCH=$(ocamlc -config | grep "^architecture:" | awk '{print $2}')
  echo "  Detected architecture: ${DETECTED_ARCH}"

  # Build cppo using dune (cppo uses dune build system)
  if command -v dune &>/dev/null; then
    echo "Building cppo with dune..."
    dune build --profile=release -p "${DUNE_PACKAGES}"
  else
    echo "ERROR: dune not found - cppo requires dune build system"
    exit 1
  fi

elif is_non_unix; then
  # ===========================================================================
  # WINDOWS BUILD PATH
  # ===========================================================================
  echo "=== Windows build ==="

  # Build cppo using dune
  if command -v dune &>/dev/null; then
    echo "Building cppo with dune..."
    dune build --profile=release -p "${DUNE_PACKAGES}"
  else
    echo "ERROR: dune not found - cppo requires dune build system"
    exit 1
  fi

else
  # ===========================================================================
  # NATIVE UNIX BUILD (Linux/macOS native)
  # ===========================================================================
  echo "=== Native build ==="

  # Build cppo using dune
  if command -v dune &>/dev/null; then
    echo "Building cppo with dune..."
    dune build --profile=release -p "${DUNE_PACKAGES}"
  else
    echo "ERROR: dune not found - cppo requires dune build system"
    exit 1
  fi
fi

# ==============================================================================
# INSTALL
# ==============================================================================

dune install --prefix="${CPPO_INSTALL_PREFIX}" --libdir="${CPPO_INSTALL_PREFIX}"/lib/ocaml ${DUNE_PACKAGES//,/ }

# ==============================================================================
# VERIFY INSTALLATION
# ==============================================================================

# Check for cppo binary in the correct location
if is_non_unix; then
  CPPO_BIN="${CPPO_INSTALL_PREFIX}/bin/cppo.exe"
  ALT_CPPO_BIN="${CPPO_INSTALL_PREFIX}/bin/cppo"
else
  CPPO_BIN="${CPPO_INSTALL_PREFIX}/bin/cppo"
  ALT_CPPO_BIN="${CPPO_INSTALL_PREFIX}/bin/cppo.exe"
fi

if [[ -f "${CPPO_BIN}" ]] || [[ -f "${ALT_CPPO_BIN}" ]]; then
  # Use whichever exists
  [[ -f "${CPPO_BIN}" ]] && ACTUAL_BIN="${CPPO_BIN}" || ACTUAL_BIN="${ALT_CPPO_BIN}"

  echo "=== cppo installed successfully ==="
  echo "Binary: ${ACTUAL_BIN}"

  # For cross-compilation, verify it's BUILD arch (NOT target arch)
  # cppo runs on build machine, so it must be native to build platform
  if is_cross_compile; then
    file "${ACTUAL_BIN}"
    # Expected BUILD arch patterns
    if file "${ACTUAL_BIN}" | grep -qE "(x86-64|x86_64)"; then
      echo "✓ Binary is correctly built for BUILD architecture (x86_64)"
    else
      echo "⚠ WARNING: cppo should be BUILD arch (x86_64), not TARGET arch"
      echo "  This is a BUILD-TIME tool that runs on the build machine!"
      file "${ACTUAL_BIN}"
      exit 1
    fi
  elif ! is_non_unix; then
    # Native Unix build - show file info (optional)
    file "${ACTUAL_BIN}" || true
  fi

  # Windows: file command unavailable, just verify binary exists and is non-empty
  if is_non_unix; then
    if [[ -s "${ACTUAL_BIN}" ]]; then
      echo "✓ Binary exists and is non-empty"
    else
      echo "⚠ WARNING: Binary is empty or missing"
      exit 1
    fi
  fi
else
  echo "ERROR: cppo binary not found at ${CPPO_BIN} or ${ALT_CPPO_BIN}"
  exit 1
fi

echo "=== cppo build complete ==="
