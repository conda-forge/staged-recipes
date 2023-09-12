@echo off
setlocal EnableDelayedExpansion

set HEADERS_NAME=!PKG_NAME:-headers=!
set STATIC_NAME=!PKG_NAME:-static=!

if "!HEADERS_NAME!"=="%PKG_NAME%" (
  if "!STATIC_NAME!"=="%PKG_NAME%" (
    set SECP256K1_BUILD_SHARED_LIBS="ON"
    set SECP256K1_INSTALL_HEADERS="OFF"
    set SECP256K1_INSTALL="ON"
    set LOCAL_INSTALL_PREFIX="%LIBRARY_PREFIX%"
    mkdir build
    cd build
  ) else (
    set SECP256K1_BUILD_SHARED_LIBS="OFF"
    set SECP256K1_INSTALL_HEADERS="OFF"
    set SECP256K1_INSTALL="ON"
    set LOCAL_INSTALL_PREFIX="%LIBRARY_PREFIX%"
    mkdir build-static
    cd build-static
  )
) else (
  set BUILD_DIR="build-headers"
  set SECP256K1_BUILD_SHARED_LIBS="OFF"
  set SECP256K1_INSTALL_HEADERS="ON"
  set SECP256K1_INSTALL="OFF"
  set LOCAL_INSTALL_PREFIX="%LIBRARY_PREFIX%"
  mkdir build-headers
  cd build-headers
)

cmake %CMAKE_ARGS% ^
    -S %SRC_DIR% ^
    -B . ^
    -D CMAKE_BUILD_TYPE=Release ^
    -D CMAKE_PREFIX_PATH=%PREFIX% ^
    -D CMAKE_INSTALL_PREFIX=%LOCAL_INSTALL_PREFIX% ^
    -D SECP256K1_ENABLE_MODULE_RECOVERY=ON ^
    -D BUILD_SHARED_LIBS=%SECP256K1_BUILD_SHARED_LIB% ^
    -D SECP256K1_INSTALL_HEADERS=%SECP256K1_INSTALL_HEADERS% ^
    -D SECP256K1_INSTALL=%SECP256K1_INSTALL%
if %ERRORLEVEL% neq 0 exit 1

if "!HEADERS_NAME!"=="%PKG_NAME%" (
    cmake --build .
    if %ERRORLEVEL% neq 0 exit 1
    :: cmake --build . --target check
    :: if %ERRORLEVEL% neq 0 exit 1
    cmake --build . --target install
    if %ERRORLEVEL% neq 0 exit 1
) else (
    cmake --install .
    if %ERRORLEVEL% neq 0 exit 1
)
cd ..
