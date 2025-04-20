_setup_env() {
  echo "Setting up the environment..."
  SOURCEDIR=$(realpath "${1:-${SRC_DIR}}")
  BUILDROOT=$(realpath "${SOURCEDIR}/$2-build")
  PYPROJECTROOT=${BUILDROOT}/pgadmin4
  
  SHAREROOT=${PREFIX}/share/pgadmin4
  DOCSROOT=${SHAREROOT}/docs/html
  
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
  pushd "${SOURCEDIR}"/docs/en_US || exit
    ${PYTHON} build_code_snippet.py
    sphinx-build -W -b html -d _build/doctrees . _build/html
  popd
  (cd "${SOURCEDIR}"/docs/en_US/_build/html/ && tar cf - ./* | (cd "${DOCSROOT}"/ && tar xf -)) > /dev/null 2>&1
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
      yarn set version berry
      yarn set version 3
      yarn plugin import workspace-tools
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
    yarn set version berry
    yarn set version 3
    yarn install > /dev/null 2>&1
    yarn run bundle > /dev/null 2>&1

    set +x
    find . -mindepth 1 \
      -not -path "*/node_modules/*" \
      -not -path "*/regression/*" \
      -not -path "*/tools/*" \
      -not -path "*/pgadmin/static/js/generated/.cache/*" \
      -not -path "*/tests/*" \
      -not -path "*/feature_tests/*" \
      -not -path "*/__pycache__/*" \
      -not -name "pgadmin4.db" \
      -not -name "config_local.*" \
      -not -name "jest.config.js" \
      -not -name "babel.*" \
      -not -name "package.json" \
      -not -name ".yarn*" \
      -not -name "yarn*" \
      -not -name ".editorconfig" \
      -not -name ".eslint*" \
      -not -name "pgAdmin4.wsgi" \
      -print0 | while IFS= read -r -d $'\0' FILE; do
        tar cf - "${FILE}" | (cd "${PYPROJECTROOT}"; tar xf -)
    done
    set -x
  popd > /dev/null || exit
}

