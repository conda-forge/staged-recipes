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

  echo RECIPE_DIR is %RECIPE_DIR%
  echo TEST_DIR is %TEST_DIR% or %TEST_DIR%" or !TEST_DIR! or "!TEST_DIR!"

  cp "%SRC_DIR%\src\tests.c" "%RECIPE_DIR%\!TEST_DIR!\src"
  cp "%SRC_DIR%\src\tests_exhaustive.c" "%RECIPE_DIR%\!TEST_DIR!\src"
  cp "%SRC_DIR%\src\secp256k1.c" "%RECIPE_DIR%\!TEST_DIR!\src"

  call :CopyFiles "%SRC_DIR%" "%RECIPE_DIR%\!TEST_DIR!" "%SRC_DIR%\src\*.h"
  call :CopyFiles "%SRC_DIR%" "%RECIPE_DIR%\!TEST_DIR!" "%SRC_DIR%\src\modules\*\*.h"
  call :CopyFiles "%SRC_DIR%" "%RECIPE_DIR%\!TEST_DIR!" "%SRC_DIR%\src\wycheproof\*.h"
  call :CopyFiles "%SRC_DIR%" "%RECIPE_DIR%\!TEST_DIR!" "%SRC_DIR%\contrib\*.h"
  call :CopyFiles "%SRC_DIR%" "%RECIPE_DIR%\!TEST_DIR!" "%SRC_DIR%\include\*.h"
  call :CopyFiles "%SRC_DIR%" "%RECIPE_DIR%\!TEST_DIR!\src" "%SRC_DIR%\cmake\*"
)

dir %RECIPE_DIR%\!TEST_DIR!
dir %RECIPE_DIR%\!TEST_DIR!\src

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

:CopyFiles
  set "SRC_DIR=%~1"
  set "TEST_DIR=%~2"
  set "SRC_DIR_FILES=%~3"

  echo DEBUG %SRC_DIR% to %TEST_DIR% for %SRC_DIR_FILES%

  for %%f in (%SRC_DIR_FILES%) do (
    set "FULL_PATH=%%~f"
    set "FILE=%%~nxf"
    set "FILE_PATH=!FULL_PATH:%SRC_DIR%\=!"
    set "DIR=!FILE_PATH:%%~nxf=!"

    rem Remove trailing backslash if exists
    if "!DIR:~-1!"=="\" set "DIR=!DIR:~0,-1!"

    if not exist "%TEST_DIR%\!DIR!" (
      echo Creating: "%TEST_DIR%\!DIR!"
      mkdir "%TEST_DIR%\!DIR!"
    )

    cp "%%~f" "%TEST_DIR%\!FILE_PATH!"
    if %ERRORLEVEL% neq 0 exit /b 1
  )
exit /b 0


