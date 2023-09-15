@echo off
setlocal EnableDelayedExpansion

set HEADERS_NAME=!PKG_NAME:-headers=!
set STATIC_NAME=!PKG_NAME:-static=!

:: Prepare post-install tests
if "!HEADERS_NAME!"=="%PKG_NAME%" (
  copy "%SRC_DIR%\src\tests.c" "%RECIPE_DIR%\standalone_tests\src"
  cp "%SRC_DIR%\src\tests_exhaustive.c" "%RECIPE_DIR%\standalone_tests\src"
  cp "%SRC_DIR%\src\secp256k1.c" "%RECIPE_DIR%\standalone_tests\src"
  cd "%SRC_DIR%" && (
      tar cf - contrib\lax_der_parsing.c contrib\lax_der_privatekey_parsing.c
  ) | (
      cd "%RECIPE_DIR%\standalone_tests" && tar xf -
  )
  cd "%SRC_DIR%\src" && (
      tar cf - *.h modules\*\*.h wycheproof\*.h
  ) | (
      cd "%RECIPE_DIR%\standalone_tests\src" && tar xf -
  )
  if %ERRORLEVEL% neq 0 exit 1
)

:: Build
if "!HEADERS_NAME!"=="%PKG_NAME%" (
  if "!STATIC_NAME!"=="%PKG_NAME%" (
    set "SECP256K1_BUILD_SHARED_LIBS=ON"
    set "SECP256K1_INSTALL_HEADERS=OFF"
    set "SECP256K1_INSTALL=ON"
    mkdir build
    cd build
  ) else (
    set "SECP256K1_BUILD_SHARED_LIBS=OFF"
    set "SECP256K1_INSTALL_HEADERS=OFF"
    set "SECP256K1_INSTALL=ON"
    mkdir build-static
    cd build-static
  )
) else (
  set "SECP256K1_BUILD_SHARED_LIBS=OFF"
  set "SECP256K1_INSTALL_HEADERS=ON"
  set "SECP256K1_INSTALL=OFF"
  mkdir build-headers
  cd build-headers
)

cmake %CMAKE_ARGS% ^
    -S %SRC_DIR% ^
    -B . ^
    -D CMAKE_BUILD_TYPE=Release ^
    -D CMAKE_PREFIX_PATH=%PREFIX% ^
    -D CMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -D SECP256K1_ENABLE_MODULE_RECOVERY=ON ^
    -D BUILD_SHARED_LIBS=%SECP256K1_BUILD_SHARED_LIBS% ^
    -D SECP256K1_INSTALL_HEADERS=%SECP256K1_INSTALL_HEADERS% ^
    -D SECP256K1_INSTALL=%SECP256K1_INSTALL% ^
    -D SECP256K1_BUILD_BENCHMARKS=OFF ^
    -D SECP256K1_BUILD_TESTS=ON ^
    -D SECP256K1_BUILD_EXHAUSTIVE_TESTS=OFF
if %ERRORLEVEL% neq 0 exit 1

if "!HEADERS_NAME!"=="%PKG_NAME%" (
    cmake --build .
    if %ERRORLEVEL% neq 0 exit 1
    cmake --build . --target tests
    if %ERRORLEVEL% neq 0 exit 1
    cmake --build . --target install
    if %ERRORLEVEL% neq 0 exit 1
) else (
    cmake --install .
    if %ERRORLEVEL% neq 0 exit 1
)
cd ..
