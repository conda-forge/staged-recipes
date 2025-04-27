#!/usr/bin/env bash
set -eux

set +x
if [[ "${target_platform}" == "win-64" ]]; then
  _PREFIX="${PREFIX}"/Library
  export PREFIX=${_PREFIX}
fi

export PYTHONDONTWRITEBYTECODE=1
export PG_YARN=${PREFIX}/bin/yarn

source "${RECIPE_DIR}"/building/build-functions.sh
set -x

_setup_env "${SRC_DIR}" "conda"
_cleanup "whl"
_setup_dirs
_build_docs
_build_py_project

echo "HELP_PATH = '${PREFIX}/share/pgadmin4/docs/html/'" > "${PYPROJECTROOT}"/config_distro.py
echo "MINIFY_HTML = False" >> "${PYPROJECTROOT}"/config_distro.py

cp LICENSE DEPENDENCIES README.md "${BUILDROOT}"

# Build/Install python package
pushd "${BUILDROOT}" || exit
  echo "Installing..."
  echo "" | cat > pgadmin4/__init__.py

  ${PYTHON} "${RECIPE_DIR}"/building/generate_pyproject.py \
    --setup "${SRC_DIR}"/pkg/pip/setup_pip.py \
    --req "${SRC_DIR}"/requirements.txt \
    --version "${APP_LONG_VERSION}" \
    --output pyproject.toml

  ${PYTHON} -m build -w -n -x -Cbuilddir=.

  ${PYTHON} -m pip install \
    dist/pgadmin4-"${APP_LONG_VERSION}"-py3-none-any.whl \
    -vvv \
    --no-build-isolation \
    --no-deps \
    --no-cache-dir
popd

# Cleanup (in particular since tests mounts web)
rm -rf web/pgadmin/static/js/generated/*
rm -rf web/pgadmin/static/js/generated/.cache
rm -rf web/pgadmin/static/css/generated/*
rm -rf web/pgadmin/static/css/generated/.cache

rm -rf web/node-modules/

# rm -rf conda-build/
