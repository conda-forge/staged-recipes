#!/usr/bin/env bash
set -euxo pipefail

# ==============================================================================
# MENHIR BUILD SCRIPT (Standalone Recipe)
# ==============================================================================
# Build the Menhir parser generator for OCaml using Dune.
# Standalone version - source extracts to ${SRC_DIR} directly.
#
# CRITICAL: For cross-compilation, menhir is a BUILD TOOL that runs on the
# BUILD machine, not the TARGET. It generates .ml/.mli from .mly grammars.
# ==============================================================================

source "${RECIPE_DIR}/building/build_functions.sh"

# ==============================================================================
# ENVIRONMENT SETUP
# ==============================================================================

cd "${SRC_DIR}"

# macOS: Set library path for zstd
if is_macos; then
  export DYLD_FALLBACK_LIBRARY_PATH="${BUILD_PREFIX}/lib:${PREFIX}/lib:${DYLD_FALLBACK_LIBRARY_PATH:-}"
fi

# Set install prefix
if is_non_unix; then
  export MENHIR_INSTALL_PREFIX="${_PREFIX_}/Library"
  export PATH="${BUILD_PREFIX}/bin:${BUILD_PREFIX}/Library/bin:${PATH}"
else
  export MENHIR_INSTALL_PREFIX="${PREFIX}"
fi

# ==============================================================================
# BUILD
# ==============================================================================

echo "=== Cross-compilation detection ==="
echo "  CONDA_BUILD_CROSS_COMPILATION: ${CONDA_BUILD_CROSS_COMPILATION:-not set}"
echo "  is_cross_compile: $(is_cross_compile && echo 'true' || echo 'false')"

if is_cross_compile; then
  echo "=== Cross-compilation build ==="
  echo "CRITICAL: Building menhir for BUILD architecture (it's a build tool)"

  # Use BUILD_PREFIX compiler, NOT cross-compiler
  export PATH="${BUILD_PREFIX}/bin:${PATH}"

  echo "Compiler check:"
  echo "  ocamlopt: $(which ocamlopt)"
  ocamlopt -config | grep -E "^architecture:" || true

  dune build @install
  dune install --prefix="${MENHIR_INSTALL_PREFIX}" --libdir="${MENHIR_INSTALL_PREFIX}/lib" --mandir="${MENHIR_INSTALL_PREFIX}/share/man"

elif is_non_unix; then
  echo "=== Windows build ==="
  export PATH="${BUILD_PREFIX}/Library/mingw-w64/bin:${BUILD_PREFIX}/Library/bin:${BUILD_PREFIX}/bin:${PATH}"

  dune build @install
  dune install --prefix="${MENHIR_INSTALL_PREFIX}" --libdir="${MENHIR_INSTALL_PREFIX}/lib" --mandir="${MENHIR_INSTALL_PREFIX}/share/man"

else
  echo "=== Native build ==="
  dune build @install
  dune install --prefix="${MENHIR_INSTALL_PREFIX}" --libdir="${MENHIR_INSTALL_PREFIX}/lib" --mandir="${MENHIR_INSTALL_PREFIX}/share/man"
fi

# ==============================================================================
# VERIFY INSTALLATION
# ==============================================================================

if is_non_unix; then
  MENHIR_BIN="${MENHIR_INSTALL_PREFIX}/bin/menhir.exe"
  ALT_MENHIR_BIN="${MENHIR_INSTALL_PREFIX}/bin/menhir"
else
  MENHIR_BIN="${MENHIR_INSTALL_PREFIX}/bin/menhir"
  ALT_MENHIR_BIN="${MENHIR_INSTALL_PREFIX}/bin/menhir.exe"
fi

if [[ -f "${MENHIR_BIN}" ]] || [[ -f "${ALT_MENHIR_BIN}" ]]; then
  [[ -f "${MENHIR_BIN}" ]] && ACTUAL_BIN="${MENHIR_BIN}" || ACTUAL_BIN="${ALT_MENHIR_BIN}"

  echo "=== Menhir installed successfully ==="
  echo "Binary: ${ACTUAL_BIN}"

  if ! is_non_unix; then
    file "${ACTUAL_BIN}" || true
  fi
else
  echo "ERROR: Menhir binary not found at ${MENHIR_BIN} or ${ALT_MENHIR_BIN}"
  exit 1
fi

echo "=== Menhir build complete ==="
