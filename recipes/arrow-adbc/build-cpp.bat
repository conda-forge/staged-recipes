if "%PKG_NAME%" == "adbc-driver-manager-cpp" (
    set PKG_ROOT=c\driver_manager
    goto BUILD
)
if "%PKG_NAME%" == "adbc-driver-postgresql-cpp" (
    set PKG_ROOT=c\driver\postgresql
    goto BUILD
)
if "%PKG_NAME%" == "adbc-driver-sqlite-cpp" (
    set PKG_ROOT=c\driver\sqlite
    goto BUILD
)
echo Unknown package %PKG_NAME%
exit 1

:BUILD

mkdir "%SRC_DIR%"\build-cpp\%PKG_NAME%
pushd "%SRC_DIR%"\build-cpp\%PKG_NAME%

cmake ..\..\%PKG_ROOT% ^
      -G Ninja ^
      -DADBC_BUILD_SHARED=ON ^
      -DADBC_BUILD_STATIC=OFF ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -DCMAKE_PREFIX_PATH=%PREFIX% ^
      || exit /B 1

cmake --build . --target install --config Release -j || exit /B 1

popd
