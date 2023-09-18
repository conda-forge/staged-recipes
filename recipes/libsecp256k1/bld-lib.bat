@echo off
setlocal EnableDelayedExpansion

set HEADERS_NAME=!PKG_NAME:-headers=!
set STATIC_NAME=!PKG_NAME:-static=!

:: Prepare post-install tests
if "!HEADERS_NAME!"=="%PKG_NAME%" (
  if "!STATIC_NAME!"=="%PKG_NAME%" (
    set "TEST_DIR=shared_standalone_tests"
  ) else (
    set "TEST_DIR=static_standalone_tests"
  )
  cp "%SRC_DIR%\\src\\tests.c" "%TEST_DIR%\\src"
  cp "%SRC_DIR%\src\\tests_exhaustive.c" "%TEST_DIR%\\src"
  cp "%SRC_DIR%\\src\\secp256k1.c" "%TEST_DIR%\\src"

  for /f "delims=" %%f in ('dir /b /s /a-d %SRC_DIR%\\contrib\\* %SRC_DIR%\\include\\*') do (
      set "FILE=%%f"
      set "FILE=!FILE:%SRC_DIR%=!"
      set "FILE=!FILE:\=\\!"
      mkdir "%TEST_DIR%\\!FILE:~0,-2!"
      cp "%%f" "%TEST_DIR%\\!FILE!"
  )
  if %ERRORLEVEL% neq 0 exit 1

  for /f "delims=" %%f in ('dir /b /s /a-d %SRC_DIR%\\cmake\\*') do (
      set "FILE=%%f"
      set "FILE=!FILE:%SRC_DIR%=!"
      set "FILE=!FILE:\=\\!"
      mkdir "%TEST_DIR%\\src\\!FILE:~0,-2!"
      cp "%%f" "%TEST_DIR%\\src\\!FILE!"
  )
  if %ERRORLEVEL% neq 0 exit 1

  for /f "delims=" %%f in ('dir /b /s /a-d %SRC_DIR%\\src\\*.h %SRC_DIR%\\src\\modules\\*\\*.h %SRC_DIR%\\src\\wycheproof\\*.h') do (
      set "FILE=%%f"
      set "FILE=!FILE:%SRC_DIR%=!"
      set "FILE=!FILE:\=\\!"
      mkdir "%TEST_DIR%\\src\\!FILE:~0,-2!"
      cp "%%f" "%TEST_DIR%\\src\\!FILE!"
  )
  if %ERRORLEVEL% neq 0 exit 1
)

:: Build
if "!HEADERS_NAME!"=="%PKG_NAME%" (
  if "!STATIC_NAME!"=="%PKG_NAME%" (
    set "SECP256K1_BUILD_SHARED_LIBS=ON"
    set "SECP256K1_INSTALL_HEADERS=OFF"
    set "SECP256K1_INSTALL=ON"

    set "BUILD_DIR=build"
  ) else (
    set "SECP256K1_BUILD_SHARED_LIBS=OFF"
    set "SECP256K1_INSTALL_HEADERS=OFF"
    set "SECP256K1_INSTALL=ON"

    set "BUILD_DIR=build-static"
  )
) else (
  set "SECP256K1_BUILD_SHARED_LIBS=OFF"
  set "SECP256K1_INSTALL_HEADERS=ON"
  set "SECP256K1_INSTALL=OFF"

  set "BUILD_DIR=build-headers"
)

mkdir %BUILD_DIR%
cd %BUILD_DIR%

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
rmdir /s /q %BUILD_DIR%