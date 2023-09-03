setlocal EnableDelayedExpansion
@echo on

set BUILD_DIR=build

mkdir "%BUILD_DIR%"
if errorlevel 1 exit 1

cd "%BUILD_DIR%"
if errorlevel 1 exit 1

cmake ..    -D CMAKE_PREFIX_PATH="%PREFIX%" ^
            -D CMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
            "%CMAKE_ARGS%" ^
            -D SECP256K1_ENABLE_MODULE_ECDH=ON ^
            -D SECP256K1_ENABLE_MODULE_RECOVERY=OFF ^
            -D SECP256K1_ENABLE_MODULE_EXTRAKEYS=ON ^
            -D SECP256K1_ENABLE_MODULE_SCHNORRSIG=ON ^
            -D SECP256K1_EXPERIMENTAL=OFF ^
            -D SECP256K1_USE_EXTERNAL_DEFAULT_CALLBACKS=OFF ^
            -D SECP256K1_INSTALL=ON
if errorlevel 1 exit 1

cmake --build . --target install "%CMAKE_BUILD_OPTIONS%"
if errorlevel 1 exit 1

