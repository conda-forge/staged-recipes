#!/usr/bin/env bash
set -eux

set +x
if [[ "${target_platform}" == "win-64" ]]; then
  _PREFIX="${PREFIX}"/Library
  export PREFIX=${_PREFIX}
fi

source "${RECIPE_DIR}"/building/build-functions.sh
set -x

_setup_env "${SRC_DIR}" "conda"
_setup_dirs

cp web/pgAdmin4.wsgi "${SHAREROOT}"
cp LICENSE DEPENDENCIES README.md ${BUILDROOT}

# MenuInst
mkdir "${PREFIX}"/Menu
cp "${SOURCEDIR}/pkg/linux/pgadmin4.desktop" "${PREFIX}"/Menu
