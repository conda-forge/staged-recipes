#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

mkdir -p "${PREFIX}/etc"
cp "${RECIPE_DIR}/dirac.cfg" "${PREFIX}/etc/dirac.cfg"

# vomsdir
mkdir -p "${PREFIX}/etc/grid-security/vomsdir"
cp -r "${RECIPE_DIR}/vomsdir-lhcb" "${PREFIX}/etc/grid-security/vomsdir/lhcb"

# vomses
mkdir -p "${PREFIX}/etc/grid-security/vomses"
cp "${RECIPE_DIR}/vomses-lhcb" "${PREFIX}/etc/grid-security/vomses/lhcb"

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
