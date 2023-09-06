setlocal EnableDelayedExpansion
@echo on

set BUILD_DIR=build

mkdir "%BUILD_DIR%"
if errorlevel 1 exit 1

cd "%BUILD_DIR%"
if errorlevel 1 exit 1

cmake %CMAKE_ARGS% ^
    -G Ninja ^
    -S %SRC_DIR% ^
    -B . ^
    -D CMAKE_BUILD_TYPE=Release ^
    -D CMAKE_PREFIX_PATH="%PREFIX%" ^
    -D CMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -D SECP256K1_ENABLE_MODULE_RECOVERY=%SECP256K1_ENABLE_MODULE_RECOVERY% ^
    -D SECP256K1_INSTALL=ON

cmake  --build .
if errorlevel 1 exit 1

cmake --build . --target check
if errorlevel 1 exit 1

cmake --build . --target install
if errorlevel 1 exit 1

