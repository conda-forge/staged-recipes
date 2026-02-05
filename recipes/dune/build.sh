#!/usr/bin/env bash
set -euxo pipefail

# ==============================================================================
# DUNE BUILD SCRIPT (Standalone Recipe)
# ==============================================================================
# Build the Dune build system for OCaml using the upstream Makefile.
# Standalone version - source extracts to ${SRC_DIR} directly.
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
  export DUNE_INSTALL_PREFIX="${_PREFIX_}/Library"
  export PATH="${BUILD_PREFIX}/bin:${BUILD_PREFIX}/Library/bin:${PATH}"
else
  export DUNE_INSTALL_PREFIX="${PREFIX}"
fi

# ==============================================================================
# BUILD
# ==============================================================================

echo "=== Cross-compilation detection ==="
echo "  CONDA_BUILD_CROSS_COMPILATION: ${CONDA_BUILD_CROSS_COMPILATION:-not set}"
echo "  is_cross_compile: $(is_cross_compile && echo 'true' || echo 'false')"

if is_cross_compile; then
  echo "=== Cross-compilation build ==="

  # Phase 1: Bootstrap native dune
  make release
  NATIVE_DUNE="_boot/dune.exe"
  cp -v _boot/dune.exe ./_native_dune

  # Rebuild .duneboot.exe with native compiler
  ocamlc -output-complete-exe -intf-suffix .dummy -g -o ./_native_duneboot \
    -I boot -I +unix unix.cma boot/types.ml boot/libs.ml boot/duneboot.ml

  # Phase 2: Swap to cross-compilers
  swap_ocaml_compilers
  setup_cross_c_compilers
  configure_cross_environment
  if is_macos; then
    create_macos_ocamlmklib_wrapper
  fi
  patch_ocaml_makefile_config

  # Clear build cache
  rm -rf _build
  rm -f _boot/*.{cmi,cmx,cma,cmxa,o,a} 2>/dev/null || true

  # Phase 3: Rebuild with cross-compiler
  ./_native_duneboot

  mkdir -p _build/default/bin
  cp -v _boot/dune.exe _build/default/bin/dune.exe

elif is_non_unix; then
  echo "=== Windows build ==="
  export PATH="${BUILD_PREFIX}/Library/mingw-w64/bin:${BUILD_PREFIX}/Library/bin:${BUILD_PREFIX}/bin:${PATH}"
  make release
else
  echo "=== Native build ==="
  make release
fi

# ==============================================================================
# INSTALL
# ==============================================================================

if is_cross_compile; then
  mkdir -p "${DUNE_INSTALL_PREFIX}/bin"
  cp -v _build/default/bin/dune.exe "${DUNE_INSTALL_PREFIX}/bin/dune"
  chmod +x "${DUNE_INSTALL_PREFIX}/bin/dune"
else
  make PREFIX="${DUNE_INSTALL_PREFIX}" install
fi

# ==============================================================================
# INSTALL ACTIVATION SCRIPTS
# ==============================================================================

ACTIVATE_DIR="${PREFIX}/etc/conda/activate.d"
DEACTIVATE_DIR="${PREFIX}/etc/conda/deactivate.d"
mkdir -p "${ACTIVATE_DIR}" "${DEACTIVATE_DIR}"

if is_non_unix; then
  cp "${RECIPE_DIR}/activation/dune-activate.bat" "${ACTIVATE_DIR}/dune-activate.bat"
  cp "${RECIPE_DIR}/activation/dune-deactivate.bat" "${DEACTIVATE_DIR}/dune-deactivate.bat"
else
  cp "${RECIPE_DIR}/activation/dune-activate.sh" "${ACTIVATE_DIR}/dune-activate.sh"
  cp "${RECIPE_DIR}/activation/dune-deactivate.sh" "${DEACTIVATE_DIR}/dune-deactivate.sh"
fi

# ==============================================================================
# WRITE OCAML BUILD VERSION FOR TESTS
# ==============================================================================
# Tests need to know the OCaml version used during build to distinguish
# between known bugs (OCaml <= 5.3.0) and real failures (OCaml >= 5.4.0)

TEST_FILES_DIR="${PREFIX}/etc/conda/test-files"
mkdir -p "${TEST_FILES_DIR}"
OCAML_BUILD_VERSION=$(ocamlc -version)
echo "${OCAML_BUILD_VERSION}" > "${TEST_FILES_DIR}/ocaml-build-version"
echo "Wrote OCaml build version ${OCAML_BUILD_VERSION} to ${TEST_FILES_DIR}/ocaml-build-version"

# ==============================================================================
# FIX MAN PAGE AND EMACS LOCATIONS
# ==============================================================================

mkdir -p "${DUNE_INSTALL_PREFIX}/share/man/man1"
mkdir -p "${DUNE_INSTALL_PREFIX}/share/man/man5"

if [[ -d "${DUNE_INSTALL_PREFIX}/man" ]]; then
  if [[ -d "${DUNE_INSTALL_PREFIX}/man/man1" ]] && [[ -n "$(ls -A ${DUNE_INSTALL_PREFIX}/man/man1)" ]]; then
    mv "${DUNE_INSTALL_PREFIX}"/man/man1/* "${DUNE_INSTALL_PREFIX}/share/man/man1/"
  fi
  if [[ -d "${DUNE_INSTALL_PREFIX}/man/man5" ]] && [[ -n "$(ls -A ${DUNE_INSTALL_PREFIX}/man/man5)" ]]; then
    mv "${DUNE_INSTALL_PREFIX}"/man/man5/* "${DUNE_INSTALL_PREFIX}/share/man/man5/"
  fi
  rm -rf "${DUNE_INSTALL_PREFIX}/man"
fi

mkdir -p "${DUNE_INSTALL_PREFIX}/share/emacs/site-lisp/dune"
if [[ -d "${DUNE_INSTALL_PREFIX}/share/emacs/site-lisp" ]]; then
  mv "${DUNE_INSTALL_PREFIX}"/share/emacs/site-lisp/*.el "${DUNE_INSTALL_PREFIX}/share/emacs/site-lisp/dune/" 2>/dev/null || true
fi

# ==============================================================================
# VERIFY INSTALLATION
# ==============================================================================

if is_non_unix; then
  DUNE_BIN="${DUNE_INSTALL_PREFIX}/bin/dune.exe"
else
  DUNE_BIN="${DUNE_INSTALL_PREFIX}/bin/dune"
fi

if [[ -f "${DUNE_BIN}" ]]; then
  echo "=== Dune installed successfully ==="
  echo "Binary: ${DUNE_BIN}"
  if ! is_non_unix; then
    file "${DUNE_BIN}" || true
    # Strip binary on Linux to reduce size (macOS: breaks code signature)
    if is_linux; then
      echo "Stripping binary..."
      strip "${DUNE_BIN}" || true
    fi
  fi
else
  echo "ERROR: Dune binary not found at ${DUNE_BIN}"
  exit 1
fi

echo "=== Dune build complete ==="
