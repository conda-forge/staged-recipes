#!/usr/bin/env bash
set -eux

if [[ "${target_platform}" == "win-64" ]]; then
  echo "PREFIX ${PREFIX}"
  _PREFIX=$(cygpath -u "${PREFIX}"/Library)
  export PREFIX=_PREFIX
  echo "PREFIX ${PREFIX}"
fi

export PYTHONDONTWRITEBYTECODE=1
source "${RECIPE_DIR}"/building/build-functions.sh

_setup_env "${SRC_DIR}" "conda"
_cleanup "whl"
_setup_dirs
_build_docs
_build_runtime
_build_py_project

cp web/pgAdmin4.wsgi "${SHAREROOT}"

echo "HELP_PATH = '${PREFIX}/share/pgadmin4/docs/html/'" > ${PYPROJECTROOT}/config_distro.py
echo "MINIFY_HTML = False" >> ${PYPROJECTROOT}/config_distro.py

cp LICENSE DEPENDENCIES README.md ${BUILDROOT}

# Run the build
echo Installing...
pushd ${BUILDROOT} || exit
  #${PYTHON} ${RECIPE_DIR}/building/generate_package_init.py \
  #  pgadmin4/config.py \
  #  pgadmin4/__init__.py
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

# python -m pip install \
#   --no-build-isolation \
#   --no-deps \
#   --prefix="${PREFIX}" \
#   conda-build/dist/*.whl
#  --target $PREFIX/lib/site-packages \

# Cleanup (in particular since tests mounts web)
rm -rf web/pgadmin/static/js/generated/*
rm -rf web/pgadmin/static/js/generated/.cache
rm -rf web/pgadmin/static/css/generated/*
rm -rf web/pgadmin/static/css/generated/.cache

rm -rf web/node-modules/

# Remove links from corepack
rm -rf ${PREFIX}/python-scripts/{pnpm,pnpx,yarn,yarnpkg}

# rm -rf conda-build/

