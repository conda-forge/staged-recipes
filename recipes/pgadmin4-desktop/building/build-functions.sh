_setup_env() {
  echo "Setting up the environment..."
  BUILDROOT="${SRC_DIR}"/conda-build
  DESKTOPROOT="${SRC_DIR}"/desktop

  if [[ "${OSTYPE}" == "linux"* ]] || [[ "${OSTYPE}" == "darwin"* ]]; then
    APP_RELEASE=$(grep "^APP_RELEASE" web/version.py | cut -d"=" -f2 | sed 's/ //g')
    APP_REVISION=$(grep "^APP_REVISION" web/version.py | cut -d"=" -f2 | sed 's/ //g')
    APP_NAME=$(grep "^APP_NAME" web/branding.py | cut -d"=" -f2 | sed "s/'//g" | sed 's/^ //' | sed 's/ //g' | tr '[:upper:]' '[:lower:]')
    APP_SUFFIX=$(grep "^APP_SUFFIX" web/version.py | cut -d"=" -f2 | sed 's/ //g' | sed "s/'//g")
  else
    # Process PowerShell output line by line, explicitly removing carriage returns
    while IFS= read -r line; do
      # Replace any carriage returns in the line
      clean_line=$(echo "$line" | tr -d '\r')
      export "$clean_line"
    done < <(powershell.exe -ExecutionPolicy Bypass -File "${RECIPE_DIR}"/building/version-info.ps1)
  fi

  APP_LONG_VERSION=${APP_RELEASE}.${APP_REVISION}
  if [ -n "${APP_SUFFIX}" ]; then
      APP_LONG_VERSION="${APP_LONG_VERSION}-${APP_SUFFIX}"
  fi

  PYTHON_BINARY=$("${PYTHON}" -c "import sys; print('python%d.%.d' % (sys.version_info.major, sys.version_info.minor))")

  SHAREROOT="${DESKTOPROOT}"/share/"${APP_NAME}"
  BUNDLEDIR="${DESKTOPROOT}"/usr/"${APP_NAME}"/bin
  if [[ "${OSTYPE}" == "darwin"* ]]; then
    BUNDLEDIR="${DESKTOPROOT}"/usr/${APP_NAME}.app
  fi
  MENUROOT="${DESKTOPROOT}"/Menu
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
    "${DESKTOPROOT}" \
    "${SHAREROOT}" \
    "${MENUROOT}" \
    "${BUNDLEDIR}"
  set -x
}

_install_electron() {
  set +x
  echo "Installing Electron..."
  if [[ "${OSTYPE}" == "linux"* ]] || [[ "${OSTYPE}" == "darwin"* ]]; then
    ELECTRON_OS="$(uname | tr '[:upper:]' '[:lower:]')"
    ELECTRON_VERSION="$(pnpm info electron version)"
  else
    ELECTRON_OS="win32"
    ELECTRON_VERSION="$(${PREFIX}/Library/bin/pnpm.bat info electron version)"
  fi

  ELECTRON_ARCH="x64"
  if [[ -n "${target_platform:-}" ]] && ([[ "${target_platform}" == *"-aarch64" ]] || [[ "${target_platform}" == *"-arm64" ]]); then
    ELECTRON_ARCH="arm64"
  fi

  pushd "${BUILDROOT}" > /dev/null || exit
    curl -LfO "https://github.com/electron/electron/releases/download/v${ELECTRON_VERSION}/electron-v${ELECTRON_VERSION}-${ELECTRON_OS}-${ELECTRON_ARCH}.zip"
    unzip "electron-v${ELECTRON_VERSION}-${ELECTRON_OS}-${ELECTRON_ARCH}.zip" -d "electron-v${ELECTRON_VERSION}-${ELECTRON_OS}-${ELECTRON_ARCH}" > /dev/null 2>&1
  popd > /dev/null || exit

  # Change the permission for others and group the same as the owner
  chmod -R og=u "${BUILDROOT}/electron-v${ELECTRON_VERSION}-${ELECTRON_OS}-${ELECTRON_ARCH}"/*
  chmod -R og-w "${BUILDROOT}/electron-v${ELECTRON_VERSION}-${ELECTRON_OS}-${ELECTRON_ARCH}"/*

  if [[ "${OSTYPE}" == "darwin"* ]]; then
    cp -r "${BUILDROOT}"/electron-v"${ELECTRON_VERSION}"-"${ELECTRON_OS}"-"${ELECTRON_ARCH}"/Electron.app/* "${BUNDLEDIR}"
  else
    cp -r "${BUILDROOT}/electron-v${ELECTRON_VERSION}-${ELECTRON_OS}-${ELECTRON_ARCH}"/* "${BUNDLEDIR}"
  fi

  if [[ "${OSTYPE}" == "linux"* ]]; then
    rm "${BUNDLEDIR}"/{libvulkan,libEGL,libGLESv2}.*
    ln -sf "${PREFIX}/lib/libGLESv2.so.2" "${BUNDLEDIR}/libGLESv2.so"
    ln -sf "${PREFIX}/lib/libEGL.so.1" "${BUNDLEDIR}/libEGL.so"
    ln -sf "${PREFIX}/lib/libvulkan.so" "${BUNDLEDIR}/libvulkan.so"
  fi

  if [[ "${OSTYPE}" == "linux"* ]]; then
    mv "${BUNDLEDIR}/electron" "${BUNDLEDIR}/${APP_NAME}"
  elif [[ "${OSTYPE}" == "darwin"* ]]; then
    mkdir -p "${BUNDLEDIR}/Contents/MacOS"
    mv "${BUNDLEDIR}/Contents/MacOS/Electron" "${BUNDLEDIR}/Contents/MacOS/${APP_NAME}"
  else
    mv "${BUNDLEDIR}/electron.exe" "${BUNDLEDIR}/${APP_NAME}.exe"
    "${PREFIX}"/Library/bin/rcedit "${BUNDLEDIR}/${APP_NAME}.exe" --set-icon "$SRC_DIR"/pkg/win32/Resources/pgAdmin4.ico
    "${PREFIX}"/Library/bin/rcedit "${BUNDLEDIR}/${APP_NAME}.exe" --set-version-string "FileDescription" "${APP_NAME}"
    "${PREFIX}"/Library/bin/rcedit "${BUNDLEDIR}/${APP_NAME}.exe" --set-version-string "ProductName" "${APP_NAME}"
    "${PREFIX}"/Library/bin/rcedit "${BUNDLEDIR}/${APP_NAME}.exe" --set-product-version "${APP_LONG_VERSION}"
  fi
}

_build_runtime() {
  echo "Assembling the desktop runtime..."
  if [[ "${OSTYPE}" == "darwin"* ]]; then
    _DEST="${BUNDLEDIR}"/Contents/Resources/app
  else
    _DEST="${BUNDLEDIR}/resources/app"
  fi

  mkdir -p "${_DEST}"
  cp -r "${SRC_DIR}/runtime/assets" "${_DEST}"
  cp -r "${SRC_DIR}/runtime/src" "${_DEST}"
  cp "${SRC_DIR}/runtime/package.json" "${_DEST}"
  cp "${SRC_DIR}/runtime/.yarnrc.yml" "${_DEST}"
  pushd "${_DEST}" > /dev/null || exit
    ${PG_YARN} plugin import workspace-tools
    ${PG_YARN} workspaces focus --production > /dev/null 2>&1
    rm -rf .yarn .yarn*
  popd > /dev/null || exit
}

_install_osx_bundle() {
  echo "Completing the appbundle..."
  pushd "${SRC_DIR}"/pkg/mac || exit
    # Update the plist
    cp Info.plist.in "${BUNDLEDIR}/Contents/Info.plist"
    sed -i "s/%APPNAME%/${APP_NAME}/g" "${BUNDLEDIR}/Contents/Info.plist"
    sed -i "s/%APPVER%/${APP_LONG_VERSION}/g" "${BUNDLEDIR}/Contents/Info.plist"
    sed -i "s/%APPID%/org.pgadmin.pgadmin4/g" "${BUNDLEDIR}/Contents/Info.plist"

    # Rename helper execs and Update the plist
    for helper_exec in "Electron Helper" "Electron Helper (Renderer)" "Electron Helper (Plugin)" "Electron Helper (GPU)"
    do
      pgadmin_exec=${helper_exec//Electron/pgAdmin 4}
      mv "${BUNDLEDIR}/Contents/Frameworks/${helper_exec}.app/Contents/MacOS/${helper_exec}" "${BUNDLEDIR}/Contents/Frameworks/${helper_exec}.app/Contents/MacOS/${pgadmin_exec}"
      mv "${BUNDLEDIR}/Contents/Frameworks/${helper_exec}.app" "${BUNDLEDIR}/Contents/Frameworks/${pgadmin_exec}.app"

      mkdir -p "${BUNDLEDIR}/Contents/Frameworks/${pgadmin_exec}.app/Contents"
      info_plist="${BUNDLEDIR}/Contents/Frameworks/${pgadmin_exec}.app/Contents/Info.plist"
      cp Info.plist-helper.in "${info_plist}"
      sed -i "s/%APPNAME%/${pgadmin_exec}/g" "${info_plist}"
      sed -i "s/%APPVER%/${APP_LONG_VERSION}/g" "${info_plist}"
      sed -i "s/%APPID%/org.pgadmin.pgadmin4.helper/g" "${info_plist}"
    done

    # PkgInfo
    echo APPLPGA4 > "${BUNDLEDIR}"/Contents/PkgInfo

    # Icon
    cp pgAdmin4.icns "${BUNDLEDIR}"/Contents/Resources/app.icns

    # Rename the app in package.json so the menu looks as it should
    sed -i "s/\"name\": \"pgadmin4\"/\"name\": \"${APP_NAME}\"/g" "${BUNDLEDIR}"/Contents/Resources/app/package.json

    # copy the web directory to the bundle as it is required by runtime
    PY_PGADMIN=$(find "${PREFIX}"/lib/python3*/site-packages -type d -name "${APP_NAME}")
    ln -s "${PY_PGADMIN}" "${BUNDLEDIR}"/Contents/Resources/web

    # Update permissions to make sure all users can access installed pgadmin.
    chmod -R og=u "${BUNDLEDIR}"
    chmod -R og-w "${BUNDLEDIR}"
  popd || exit
}

_install_bundle() {
  # Install the app
  if [[ "${OSTYPE}" == "darwin"* ]]; then
    _install_osx_bundle
  else
    RELATIVE_PYTHON_PATH=$(python -c "import os; print(os.path.relpath('${PREFIX}/bin/python', '${PREFIX}/usr/${APP_NAME}/bin/resources/app/src/js'))")
    RELATIVE_PGADMIN_FILE=$(python -c "import os; print(os.path.relpath('${PREFIX}/lib/${PYTHON_BINARY}/site-packages/${APP_NAME}/pgAdmin4.py', '${PREFIX}/usr/${APP_NAME}/bin/resources/app/src/js'))")

    mkdir -p "${BUNDLEDIR}"/resources/app/src/js
    cat << EOF > "${BUNDLEDIR}/resources/app/src/js/dev_config.json"
{
    "pythonPath": "${RELATIVE_PYTHON_PATH}",
    "pgadminFile": "${RELATIVE_PGADMIN_FILE}"
}
EOF
  fi

  pushd "${DESKTOPROOT}" || exit 1
    if [[ "${OSTYPE}" == "linux"* ]] || [[ "${OSTYPE}" == "darwin"* ]]; then
      tar cf - ./* | (cd "${PREFIX}" || exit; tar xf -)
    else
      tar cf - ./* | (cd "${PREFIX}/Library" || exit; tar xf -)
    fi
  popd || exit 1
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
  sed -E "s#__PREFIX__#${PREFIX}#g;s#__PGADMIN4__#${APP_NAME}#g" "${RECIPE_DIR}"/building/pgadmin4_menu.json > "${MENUROOT}/pgadmin4_menu.json"
  if [[ "${OSTYPE}" == "linux"* ]]; then
    cp "${SRC_DIR}/pkg/linux/pgadmin4-128x128.png" "${MENUROOT}"/pgadmin4.png
  fi
  if [[ "${OSTYPE}" == "darwin"* ]]; then
    cp "${SRC_DIR}/pkg/mac/pgadmin4.icns" "${MENUROOT}"/pgadmin4.icns
  else
    cp "${SRC_DIR}/pkg/win32/Resources/pgAdmin4.ico" "${MENUROOT}"/pgadmin4.ico
  fi
}

_generate_sbom() {
  if [[ "${OSTYPE}" == "linux"* ]]; then
    echo "Generating SBOMs..."
    syft "${DESKTOPROOT}/" -o cyclonedx-json > "${DESKTOPROOT}/usr/${APP_NAME}/sbom-desktop.json"
  fi
  if [[ "${OSTYPE}" == "darwin"* ]]; then
    echo "Generating SBOMs..."
    syft "${BUNDLEDIR}/Contents/" -o cyclonedx-json > "${BUNDLEDIR}/Contents/sbom.json"
  fi
}
