setlocal EnableDelayedExpansion
@echo on

set BUILD_DIR=build

mkdir "%BUILD_DIR%"
if errorlevel 1 exit 1

cd "%BUILD_DIR%"
if errorlevel 1 exit 1

cmake .. -DCMAKE_PREFIX_PATH="%PREFIX%" -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" "%CMAKE_ARGS%" \
         -DSECP256K1_ENABLE_MODULE_ECDH="%SECP256K1_ENABLE_MODULE_ECDH%" \
         -DSECP256K1_ENABLE_MODULE_RECOVERY="%SECP256K1_ENABLE_MODULE_RECOVERY%" \
         -DSECP256K1_ENABLE_MODULE_EXTRAKEYS="%SECP256K1_ENABLE_MODULE_EXTRAKEYS%" \
         -DSECP256K1_ENABLE_MODULE_SCHNORRSIG="%SECP256K1_ENABLE_MODULE_SCHNORRSIG%"
if errorlevel 1 exit 1

cmake --build . --target install "%CMAKE_BUILD_OPTIONS%"
if errorlevel 1 exit 1

