if "%PKG_NAME%" == "adbc-driver-flightsql" (
    pushd "%SRC_DIR%"\python\adbc_driver_flightsql
    goto BUILD
)
if "%PKG_NAME%" == "adbc-driver-manager" (
    pushd "%SRC_DIR%"\python\adbc_driver_manager
    goto BUILD
)
if "%PKG_NAME%" == "adbc-driver-postgresql" (
    pushd "%SRC_DIR%"\python\adbc_driver_postgresql
    set ADBC_POSTGRESQL_LIBRARY=%LIBRARY_BIN%\adbc_driver_postgresql.dll
    goto BUILD
)
if "%PKG_NAME%" == "adbc-driver-sqlite" (
    pushd "%SRC_DIR%"\python\adbc_driver_sqlite
    set ADBC_SQLITE_LIBRARY=%LIBRARY_BIN%\adbc_driver_sqlite.dll
    goto BUILD
)
echo Unknown package %PKG_NAME%
exit 1

:BUILD

set SETUPTOOLS_SCM_PRETEND_VERSION=%PKG_VERSION%

echo "==== INSTALL %PKG_NAME%"
%PYTHON% -m pip install . -vvv --no-deps --no-build-isolation || exit /B 1

popd
