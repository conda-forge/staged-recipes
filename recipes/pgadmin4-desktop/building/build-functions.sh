_setup_env() {
  set +x
  echo "Setting up the environment..."
  BUILDROOT="${SRC_DIR}"/conda-build
  DESKTOPROOT="${SRC_DIR}"/desktop

  APP_RELEASE=$(grep "^APP_RELEASE" web/version.py | cut -d"=" -f2 | sed 's/ //g')
  APP_REVISION=$(grep "^APP_REVISION" web/version.py | cut -d"=" -f2 | sed 's/ //g')
  APP_NAME=$(grep "^APP_NAME" web/branding.py | cut -d"=" -f2 | sed "s/'//g" | sed 's/^ //' | sed 's/ //g' | tr '[:upper:]' '[:lower:]')
  APP_LONG_VERSION=${APP_RELEASE}.${APP_REVISION}
  APP_SUFFIX=$(grep "^APP_SUFFIX" web/version.py | cut -d"=" -f2 | sed 's/ //g' | sed "s/'//g")
  if [ -n "${APP_SUFFIX}" ]; then
      APP_LONG_VERSION="${APP_LONG_VERSION}-${APP_SUFFIX}"
  fi

  PYTHON_BINARY=$("${PREFIX}/bin/python" -c "import sys; print('python%d.%.d' % (sys.version_info.major, sys.version_info.minor))")

  SHAREROOT="${DESKTOPROOT}"/share/"${APP_NAME}"
  BUNDLEDIR="${DESKTOPROOT}"/usr/"${APP_NAME}"/bin
  MENUROOT="${DESKTOPROOT}"/Menu

  set -x
}

_cleanup() {
  set +x
  echo "Cleaning up the old environment and app..."
  rm -rf "${SRC_DIR}/runtime/pgAdmin4"
  set -x
}

_setup_dirs() {
  set +x
  echo "Creating output directories..."
  mkdir -p \
    "${BUILDROOT}" \
    "${SHAREROOT}" \
    "${MENUROOT}" \
    "${BUNDLEDIR}"
  set -x
}

_install_electron() {
  set +x
  echo "Installing Electron..."
  ELECTRON_OS="$(uname | tr '[:upper:]' '[:lower:]')"
  ELECTRON_ARCH="x64"
  if [[ "${target_platform}" == *"-aarch64" ]] || [[ "${target_platform}" == *"-arm64" ]]; then
    ELECTRON_ARCH="arm64"
  fi

  ELECTRON_VERSION="$(npm info electron version)"

  pushd "${BUILDROOT}" > /dev/null || exit
    curl -LfO "https://github.com/electron/electron/releases/download/v${ELECTRON_VERSION}/electron-v${ELECTRON_VERSION}-${ELECTRON_OS}-${ELECTRON_ARCH}.zip"
    unzip "electron-v${ELECTRON_VERSION}-${ELECTRON_OS}-${ELECTRON_ARCH}.zip" -d "electron-v${ELECTRON_VERSION}-${ELECTRON_OS}-${ELECTRON_ARCH}"
  popd > /dev/null || exit

  # Change the permission for others and group the same as the owner
  chmod -R og=u "${BUILDROOT}/electron-v${ELECTRON_VERSION}-${ELECTRON_OS}-${ELECTRON_ARCH}"/*
  chmod -R og-w "${BUILDROOT}/electron-v${ELECTRON_VERSION}-${ELECTRON_OS}-${ELECTRON_ARCH}"/*

  cp -r "${BUILDROOT}/electron-v${ELECTRON_VERSION}-${ELECTRON_OS}-${ELECTRON_ARCH}"/* "${BUNDLEDIR}"

  if [[ "${target_platform}" == "linux-"* ]]; then
    rm "${BUNDLEDIR}"/{libvulkan,libEGL,libGLESv2}.*
    ln -sf "${PREFIX}/lib/libGLESv2.so.2" "${BUNDLEDIR}/libGLESv2.so"
    ln -sf "${PREFIX}/lib/libEGL.so.1" "${BUNDLEDIR}/libEGL.so"
    ln -sf "${PREFIX}/lib/libvulkan.so" "${BUNDLEDIR}/libvulkan.so"
  fi
  mv "${BUNDLEDIR}/electron" "${BUNDLEDIR}/${APP_NAME}"
}

_build_runtime() {
  set +x
  echo "Assembling the desktop runtime..."
  mkdir -p "${BUNDLEDIR}/resources/app"
  cp -r "${SRC_DIR}/runtime/assets" "${BUNDLEDIR}/resources/app/assets"
  cp -r "${SRC_DIR}/runtime/src" "${BUNDLEDIR}/resources/app/src"

  cp "${SRC_DIR}/runtime/package.json" "${BUNDLEDIR}/resources/app"
  cp "${SRC_DIR}/runtime/.yarnrc.yml" "${BUNDLEDIR}/resources/app"
  set -x

  # Install the runtime node_modules
  set +x
  pushd "${BUNDLEDIR}/resources/app" > /dev/null || exit
    if ! ${PG_YARN} plugin runtime | grep -q "@yarnpkg/plugin-workspace-tools"; then
      ${PG_YARN} plugin import workspace-tools
    fi
    ${PG_YARN} workspaces focus --production > /dev/null 2>&1

    # remove the yarn cache
    rm -rf .yarn .yarn*
  popd > /dev/null || exit
  set -x
}

_install_bundle() {
  # Install the app
  pushd "${DESKTOPROOT}" || exit 1
    tar cf - ./* | (cd "${PREFIX}" || exit; tar xf -)
  popd || exit 1

  # Install the correct location for python and pgadmin4 python lib
  RELATIVE_PYTHON_PATH=$(realpath --relative-to="${PREFIX}/usr/${APP_NAME}/bin/resources/app/src/js" "${PREFIX}/bin/python")
  RELATIVE_PGADMIN_FILE=$(realpath --relative-to="${PREFIX}/usr/${APP_NAME}/bin/resources/app/src/js" "${PREFIX}/lib/${PYTHON_BINARY}/site-packages/${APP_NAME}/pgAdmin4.py")

  cat << EOF > "${BUNDLEDIR}/resources/app/src/js/dev_config.json"
{
    "pythonPath": "${RELATIVE_PYTHON_PATH}",
    "pgadminFile": "${RELATIVE_PGADMIN_FILE}"
}
EOF
  cp "${BUNDLEDIR}/resources/app/src/js/dev_config.json" "${PREFIX}"/usr/"${APP_NAME}"/bin/resources/app/src/js
}

_install_icons_menu(){
  # Install the icons
  mkdir -p "${DESKTOPROOT}/share/icons/hicolor/128x128/apps/"
  cp "${SRC_DIR}/pkg/linux/pgadmin4-128x128.png" "${DESKTOPROOT}/share/icons/hicolor/128x128/apps/${APP_NAME}.png"
  mkdir -p "${DESKTOPROOT}/share/icons/hicolor/64x64/apps/"
  cp "${SRC_DIR}/pkg/linux/pgadmin4-64x64.png" "${DESKTOPROOT}/share/icons/hicolor/64x64/apps/${APP_NAME}.png"
  mkdir -p "${DESKTOPROOT}/share/icons/hicolor/48x48/apps/"
  cp "${SRC_DIR}/pkg/linux/pgadmin4-48x48.png" "${DESKTOPROOT}/share/icons/hicolor/48x48/apps/${APP_NAME}.png"
  mkdir -p "${DESKTOPROOT}/share/icons/hicolor/32x32/apps/"
  cp "${SRC_DIR}/pkg/linux/pgadmin4-32x32.png" "${DESKTOPROOT}/share/icons/hicolor/32x32/apps/${APP_NAME}.png"
  mkdir -p "${DESKTOPROOT}/share/icons/hicolor/16x16/apps/"
  cp "${SRC_DIR}/pkg/linux/pgadmin4-16x16.png" "${DESKTOPROOT}/share/icons/hicolor/16x16/apps/${APP_NAME}.png"

  # Install the Menu
  if [[ "${target_platform}" == "linux-"* ]]; then
    sed -E "s#/usr/pgadmin4#${PREFIX}/usr/pgadmin4#" "${SRC_DIR}/pkg/linux/pgadmin4.desktop" > "${MENUROOT}/pgadmin4.desktop"
  fi
}

_generate_sbom() {
   echo "Generating SBOMs..."
   syft "${DESKTOPROOT}/" -o cyclonedx-json > "${DESKTOPROOT}/usr/${APP_NAME}/sbom-desktop.json"
}
