_setup_env() {
  set +x
  echo "Setting up the environment..."
  BUILDROOT="${SRC_DIR}"/conda-build

  APP_RELEASE=$(grep "^APP_RELEASE" web/version.py | cut -d"=" -f2 | sed 's/ //g')
  APP_REVISION=$(grep "^APP_REVISION" web/version.py | cut -d"=" -f2 | sed 's/ //g')
  APP_NAME=$(grep "^APP_NAME" web/branding.py | cut -d"=" -f2 | sed "s/'//g" | sed 's/^ //' | sed 's/ //g' | tr '[:upper:]' '[:lower:]')
  APP_LONG_VERSION=${APP_RELEASE}.${APP_REVISION}
  APP_SUFFIX=$(grep "^APP_SUFFIX" web/version.py | cut -d"=" -f2 | sed 's/ //g' | sed "s/'//g")
  if [ -n "${APP_SUFFIX}" ]; then
      APP_LONG_VERSION="${APP_LONG_VERSION}-${APP_SUFFIX}"
  fi

  PYPROJECTROOT="${BUILDROOT}"/${APP_NAME}
  SHAREROOT="${PREFIX}"/share/${APP_NAME}
  DOCSROOT="${SHAREROOT}"/docs/html
  set -x
}

_cleanup() {
  set +x
  echo "Cleaning up the old environment and app..."
  rm -rf "${SRC_DIR}/runtime/pgAdmin4"
  rm -rf "${BUILDROOT}"
  set -x
}

_setup_dirs() {
  echo "Creating output directories..."
  mkdir -p \
    "${BUILDROOT}" \
    "${DOCSROOT}" \
    "${PYPROJECTROOT}"
}

_build_docs() {
  echo "Building HTML documentation..."
  pushd "${SRC_DIR}"/docs/en_US || exit
    ${PYTHON} build_code_snippet.py
    sphinx-build -W -b html -d _build/doctrees . _build/html > /dev/null 2>&1
  popd || exit
  (cd "${SRC_DIR}"/docs/en_US/_build/html/ && tar cf - ./* | (cd "${DOCSROOT}"/ && tar xf -)) > /dev/null 2>&1
}

_build_py_project() {
  pushd "${SRC_DIR}/web" > /dev/null || exit
    # osx buckles on missing git repo
    git init > /dev/null 2>&1
    git config user.email "temp@example.com"
    git config user.name "Temp User"
    git add . > /dev/null 2>&1
    git commit -m "Initial commit" > /dev/null 2>&1

    ${PG_YARN} install > /dev/null 2>&1
    ${PG_YARN} run bundle > /dev/null 2>&1

    find . -type d \( -name "tests" -o -name "test_*" \) ! -path "*/__pycache__*" -print0 | \
      tar -cf "${SRC_DIR}"/tests.tar --null -T -
    rsync -a \
      --exclude='node_modules' \
      --exclude='regression' \
      --exclude='pgadmin/static/js/generated/.cache' \
      --exclude='tests' \
      --exclude='feature_tests' \
      --exclude='__pycache__' \
      --exclude='pgadmin4.db' \
      --exclude='config_local.*' \
      --exclude='jest.config.js' \
      --exclude='babel.*' \
      --exclude='package.json' \
      --exclude='.yarn*' \
      --exclude='yarn.*' \
      --exclude='.editorconfig' \
      --exclude='.eslint*' \
      --exclude='pgAdmin4.wsgi' \
      . "${PYPROJECTROOT}"
  popd > /dev/null || exit
}

