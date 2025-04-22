_setup_env() {
  echo "Setting up the environment..."
  SOURCEDIR=$(realpath "${1:-${SRC_DIR}}")
  BUILDROOT="${SOURCEDIR}/$2-build"
  PYPROJECTROOT=${BUILDROOT}/pgadmin4
  
  SHAREROOT=${PREFIX}/share/pgadmin4
  DOCSROOT=${SHAREROOT}/docs/html

  set +x
  # DESKTOPROOT=${BUILDROOT}/desktop
  # METAROOT=${BUILDROOT}/meta
  # SERVERROOT=${BUILDROOT}/server
  # WEBROOT=${BUILDROOT}/web
  # DISTROOT=$(realpath "${SOURCEDIR}/dist")
  APP_RELEASE=$(grep "^APP_RELEASE" web/version.py | cut -d"=" -f2 | sed 's/ //g')
  APP_REVISION=$(grep "^APP_REVISION" web/version.py | cut -d"=" -f2 | sed 's/ //g')
  APP_NAME=$(grep "^APP_NAME" web/branding.py | cut -d"=" -f2 | sed "s/'//g" | sed 's/^ //' | sed 's/ //g' | tr '[:upper:]' '[:lower:]')
  APP_LONG_VERSION=${APP_RELEASE}.${APP_REVISION}
  APP_SUFFIX=$(grep "^APP_SUFFIX" web/version.py | cut -d"=" -f2 | sed 's/ //g' | sed "s/'//g")
  if [ -n "${APP_SUFFIX}" ]; then
      APP_LONG_VERSION=${APP_LONG_VERSION}-${APP_SUFFIX}
  fi
  set -x
}

_cleanup() {
  echo "Cleaning up the old environment and app..."
  rm -rf "${SOURCEDIR}/runtime/pgAdmin4"
  rm -rf "${BUILDROOT}"
}

_setup_dirs() {
  echo "Creating output directories..."
  mkdir -p \
    "${BUILDROOT}" \
    "${PYPROJECTROOT}" \
    "${SHAREROOT}" \
    "${DOCSROOT}"
}

_build_docs() {
  echo "Building HTML documentation..."
  set -x
  pushd "${SOURCEDIR}"/docs/en_US || exit
    ${PYTHON} build_code_snippet.py
    sphinx-build -W -b html -d _build/doctrees . _build/html > /dev/null 2>&1
  popd
  (cd "${SOURCEDIR}"/docs/en_US/_build/html/ && tar cf - ./* | (cd "${DOCSROOT}"/ && tar xf -)) > /dev/null 2>&1
  set -x
}

_build_runtime() {
  echo "Assembling the desktop runtime..."

  mkdir -p "${SHAREROOT}/resources/app"
  cp -r "${SOURCEDIR}/runtime/assets" "${SHAREROOT}/resources/app/assets"
  cp -r "${SOURCEDIR}/runtime/src" "${SHAREROOT}/resources/app/src"

  cp "${SOURCEDIR}/runtime/package.json" "${SHAREROOT}/resources/app"
  cp "${SOURCEDIR}/runtime/.yarnrc.yml" "${SHAREROOT}/resources/app"

  # Install the runtime node_modules
  pushd "${SHAREROOT}/resources/app" > /dev/null || exit
      corepack enable
      corepack prepare yarn@3.8.7 --activate
      export PATH=$PATH:$HOME/.corepack/yarn/3.8.7/bin
      if ! yarn plugin runtime | grep -q "@yarnpkg/plugin-workspace-tools"; then
        yarn plugin import workspace-tools
      fi
      yarn workspaces focus --production

      # remove the yarn cache
      rm -rf .yarn .yarn*
  popd > /dev/null || exit

  # Create the icon
  mkdir -p "${SHAREROOT}/icons/hicolor/128x128/apps/"
  cp "${SOURCEDIR}/pkg/linux/pgadmin4-128x128.png" "${SHAREROOT}/icons/hicolor/128x128/apps/${APP_NAME}.png"
  mkdir -p "${SHAREROOT}/icons/hicolor/64x64/apps/"
  cp "${SOURCEDIR}/pkg/linux/pgadmin4-64x64.png" "${SHAREROOT}/icons/hicolor/64x64/apps/${APP_NAME}.png"
  mkdir -p "${SHAREROOT}/icons/hicolor/48x48/apps/"
  cp "${SOURCEDIR}/pkg/linux/pgadmin4-48x48.png" "${SHAREROOT}/icons/hicolor/48x48/apps/${APP_NAME}.png"
  mkdir -p "${SHAREROOT}/icons/hicolor/32x32/apps/"
  cp "${SOURCEDIR}/pkg/linux/pgadmin4-32x32.png" "${SHAREROOT}/icons/hicolor/32x32/apps/${APP_NAME}.png"
  mkdir -p "${SHAREROOT}/icons/hicolor/16x16/apps/"
  cp "${SOURCEDIR}/pkg/linux/pgadmin4-16x16.png" "${SHAREROOT}/icons/hicolor/16x16/apps/${APP_NAME}.png"

  mkdir -p "${SHAREROOT}/applications"
  cp "${SOURCEDIR}/pkg/linux/pgadmin4.desktop" "${SHAREROOT}/applications"
}

_build_py_project() {
  pushd "${SOURCEDIR}/web" > /dev/null || exit
    yarn install > /dev/null 2>&1
    yarn run bundle > /dev/null 2>&1
    # yarn licenses generate-disclaimer > "${SRC_DIR}"/JS_LICENSES

    set +x
    find . -type d \( -name "tests" -o -name "test_*" \) ! -path "*/__pycache__*" -print0 | \
      tar -cf "${SRC_DIR}/tests.tar" --null -T -

    if [[ "${target_platform}" == "win-"* ]]; then
      cmd.exe /c "robocopy \"$SOURCEDIR\web\" \"$PYPROJECTROOT\" /E /COPYALL /XD node_modules regression pgadmin/static/js/generated/.cache tests feature_tests __pycache__ /XF pgadmin4.db config_local.* jest.config.js babel.* package.json .yarn* yarn.* .editorconfig .eslint* pgAdmin4.wsgi"
    else
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
    fi

    set -x
  popd > /dev/null || exit
}

