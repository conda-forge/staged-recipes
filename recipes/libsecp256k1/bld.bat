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
    -D PYTHON_EXECUTABLE=%PYTHON% ^
    -D COMPILER=AUTO ^
    -D OPENMP=FALSE ^
    -D CUDA=%BUILD_CUDA% ^
    -D SECP256K1_ENABLE_MODULE_ECDH=ON ^
    -D SECP256K1_ENABLE_MODULE_RECOVERY=OFF ^
    -D SECP256K1_ENABLE_MODULE_EXTRAKEYS=ON ^
    -D SECP256K1_ENABLE_MODULE_SCHNORRSIG=ON ^
    -D SECP256K1_EXPERIMENTAL=OFF ^
    -D SECP256K1_USE_EXTERNAL_DEFAULT_CALLBACKS=OFF ^
    -D SECP256K1_INSTALL=ON

cmake  --build .
if errorlevel 1 exit 1

cmake --build . --target install
if errorlevel 1 exit 1

make check
if errorlevel 1 exit 1

