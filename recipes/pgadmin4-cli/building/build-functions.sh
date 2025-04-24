_setup_env() {
  set +x
  echo "Setting up the environment..."
  SOURCEDIR=$(realpath "${1:-${SRC_DIR}}")
  BUILDROOT="${SOURCEDIR}/$2-build"
  SHAREROOT="${PREFIX}"/share/pgadmin4
  MENUROOT="${PREFIX}"/Menu

  APP_RELEASE=$(grep "^APP_RELEASE" web/version.py | cut -d"=" -f2 | sed 's/ //g')
  APP_REVISION=$(grep "^APP_REVISION" web/version.py | cut -d"=" -f2 | sed 's/ //g')
  APP_NAME=$(grep "^APP_NAME" web/branding.py | cut -d"=" -f2 | sed "s/'//g" | sed 's/^ //' | sed 's/ //g' | tr '[:upper:]' '[:lower:]')
  APP_LONG_VERSION=${APP_RELEASE}.${APP_REVISION}
  APP_SUFFIX=$(grep "^APP_SUFFIX" web/version.py | cut -d"=" -f2 | sed 's/ //g' | sed "s/'//g")
  if [ -n "${APP_SUFFIX}" ]; then
      APP_LONG_VERSION="${APP_LONG_VERSION}-${APP_SUFFIX}"
  fi
  set -x
}

_setup_dirs() {
  set +x
  echo "Creating output directories..."
  mkdir -p \
    "${BUILDROOT}" \
    "${SHAREROOT}" \
    "${MENUROOT}"
  set -x
}

_install_resources() {
  set +x
  echo "Assembling the desktop runtime..."
  mkdir -p "${SHAREROOT}/resources/app"

  # Create the icon
  set +x
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

  if [[ "${target_platform}" == "linux-"* ]]; then
    cp "${SOURCEDIR}/pkg/linux/pgadmin4.desktop" "${MENUROOT}"
  fi
  set -x
}

_build_osx_app() {

}
