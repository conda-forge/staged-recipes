#!/usr/bin/env bash
set -eux

set +x
if [[ "${target_platform}" == "win-64" ]]; then
  _PREFIX="${PREFIX}"/Library
  export PREFIX=${_PREFIX}
fi

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
