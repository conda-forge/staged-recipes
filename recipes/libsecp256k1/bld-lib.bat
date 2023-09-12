@echo off
setlocal EnableDelayedExpansion

set HEADERS_NAME=!PKG_NAME:-headers=!
set STATIC_NAME=!PKG_NAME:-static=!

if "!HEADERS_NAME!"=="%PKG_NAME%" (
  if "!STATIC_NAME!"=="%PKG_NAME%" (
    set BUILD_DIR="build"
    set SECP256K1_BUILD_SHARED_LIBS="ON"
    set SECP256K1_INSTALL_HEADERS="OFF"
    set SECP256K1_INSTALL="ON"
    set LOCAL_INSTALL_PREFIX="%LIBRARY_PREFIX%"
  ) else (
    set BUILD_DIR="build-static"
    set SECP256K1_BUILD_SHARED_LIBS="OFF"
    set SECP256K1_INSTALL_HEADERS="OFF"
    set SECP256K1_INSTALL="ON"
    set LOCAL_INSTALL_PREFIX="%LIBRARY_PREFIX%"
  )
) else (
  set BUILD_DIR="build-headers"
  set SECP256K1_BUILD_SHARED_LIBS="OFF"
  set SECP256K1_INSTALL_HEADERS="ON"
  set SECP256K1_INSTALL="OFF"
  set LOCAL_INSTALL_PREFIX="%PREFIX%"
)

mkdir "%BUILD_DIR%"
if errorlevel 1 exit 1

cd "%BUILD_DIR%"
if errorlevel 1 exit 1

cmake %CMAKE_ARGS% ^
    -S %SRC_DIR% ^
    -B . ^
    -D CMAKE_BUILD_TYPE=Release ^
    -D CMAKE_PREFIX_PATH="%PREFIX%" ^
    -D CMAKE_INSTALL_PREFIX="%LOCAL_INSTALL_PREFIX%" ^
    -D SECP256K1_ENABLE_MODULE_RECOVERY=ON ^
    -D BUILD_SHARED_LIBS=%SECP256K1_BUILD_SHARED_LIB% ^
    -D SECP256K1_INSTALL_HEADERS=%SECP256K1_INSTALL_HEADERS% ^
    -D SECP256K1_INSTALL=%SECP256K1_INSTALL%

if "!HEADERS_NAME!"=="%PKG_NAME%" (
    cmake  --build .
    if errorlevel 1 exit 1
    :: cmake --build . --target check
    :: if errorlevel 1 exit 1
    cmake --build . --target install
    if errorlevel 1 exit 1
) else (
    cmake --install .
    if errorlevel 1 exit 1
)
