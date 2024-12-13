@echo off
setlocal enabledelayedexpansion
set SRC_DIR=%SRC_DIR%
set PKG_NAME=%PKG_NAME%
set PREFIX=%PREFIX%

pushd !SRC_DIR! || exit /b 1
  meson setup build-!PKG_NAME! ^
    --prefix=!PREFIX! ^
    --buildtype=release ^
    --default-library=shared ^
    --strip ^
    --backend=ninja ^
    -Dc_args="-D_CRT_SECURE_NO_WARNINGS -D_WINSOCK_DEPRECATED_NO_WARNINGS"
   if errorlevel 1 exit 1

  meson compile -C build-!PKG_NAME! -Dc_args="-D_CRT_SECURE_NO_WARNINGS -D_WINSOCK_DEPRECATED_NO_WARNINGS"
  if errorlevel 1 exit 1

  meson install -C build-!PKG_NAME!
  if errorlevel 1 exit 1
popd || exit /b 1
