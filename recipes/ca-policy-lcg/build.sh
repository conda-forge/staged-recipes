#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# List then copy the certificates
ls "${PKG_NAME}"
mkdir -p ${PREFIX}/etc/grid-security/certificates
cp -r  "${PKG_NAME}"/* "${PREFIX}/etc/grid-security/certificates"

# Actiation scripts
mkdir -p "${PREFIX}/etc/conda/activate.d"
cp "${RECIPE_DIR}/activate.sh" "${PREFIX}/etc/conda/activate.d/activate-${PKG_NAME}.sh"
cp "${RECIPE_DIR}/activate.csh" "${PREFIX}/etc/conda/activate.d/activate-${PKG_NAME}.csh"
cp "${RECIPE_DIR}/activate.fish" "${PREFIX}/etc/conda/activate.d/activate-${PKG_NAME}.fish"

# Deactivation scripts
mkdir -p "${PREFIX}/etc/conda/deactivate.d"
cp "${RECIPE_DIR}/deactivate.sh" "${PREFIX}/etc/conda/deactivate.d/deactivate-${PKG_NAME}.sh"
cp "${RECIPE_DIR}/deactivate.csh" "${PREFIX}/etc/conda/deactivate.d/deactivate-${PKG_NAME}.csh"
cp "${RECIPE_DIR}/deactivate.fish" "${PREFIX}/etc/conda/deactivate.d/deactivate-${PKG_NAME}.fish"
