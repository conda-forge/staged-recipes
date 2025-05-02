#!/usr/bin/env bash
set -eux

if [[ ${OSTYPE} == "linux"*]] || [[ ${OSTYPE} == "darwin"*]]; then
  export PG_YARN=${PREFIX}/bin/yarn
else
  export PG_YARN=${PREFIX}/Library/bin/yarn
fi

source "${RECIPE_DIR}"/building/build-functions.sh

_setup_env "${SRC_DIR}"
_cleanup
_setup_dirs
_install_electron
_build_runtime
_install_icons_menu
_install_bundle
_generate_sbom
