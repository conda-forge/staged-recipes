#!/usr/bin/env bash
set -eux

set +x
export PG_YARN=${PREFIX}/bin/yarn

source "${RECIPE_DIR}"/building/build-functions.sh
set -x

_setup_env "${SRC_DIR}"
_cleanup
_setup_dirs
_install_electron
_build_runtime
_install_icons_menu
_install_bundle
_generate_sbom
