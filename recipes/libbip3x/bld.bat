@echo off

set "build_dir=%SRC_DIR%\build-release"
set "pre_install_dir=%SRC_DIR%\pre-install"
set "test_release_dir=%SRC_DIR%\test-release"

call :configBuildInstall "%build_dir%" "%pre_install_dir%"
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

:: Remove 'toolbox' files
powershell -Command "& { Get-ChildItem -Path (Join-Path $ENV:SRC_DIR 'pre-install') -Recurse -Filter '*toolbox*' | Remove-Item -Force -Recurse }"

:: Prepare test area
powershell -Command "& { New-Item -Path (Join-Path $ENV:SRC_DIR 'test-release') -ItemType Directory -Force | Out-Null }"
powershell -Command "& { Copy-Item -Path (Join-Path $ENV:SRC_DIR 'build-release/bin') -Destination (Join-Path $ENV:SRC_DIR 'test-release') -Recurse }"

:: Process '[Gg][Tt]est' files
powershell -Command "& { Get-ChildItem -Path (Join-Path $ENV:SRC_DIR 'pre-install') -Recurse | Where-Object { $_.Name -match '[Gg][Tt]est' } | ForEach-Object { $tarFile = $_.FullName; $destination = Join-Path $ENV:SRC_DIR 'test-release'; tar -cf $tarFile | tar -xf - --transform='s,^.*/,,' -C $destination; Remove-Item -Path $tarFile -Force } }"

:: Transfer pre-install to PREFIX
powershell -Command "& { tar -cf (Join-Path $ENV:SRC_DIR 'pre-install') -C (Join-Path $ENV:SRC_DIR 'pre-install') ./* | tar -xvf - -C $ENV:PREFIX }"

:: Exit main script
GOTO :EOF

:: --- Functions ---

:configBuildInstall
setlocal
set "_build_dir=%~1"
set "_install_dir=%~2"

mkdir %_build_dir%
mkdir %_install_dir%
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
cd %_build_dir%
  set "_prefix=%PREFIX:\=\\%"
  set "_install_dir=%_install_dir:\=\\%"

  cmake %CMAKE_ARGS% ^
    -G "Ninja" ^
    -D CMAKE_BUILD_TYPE=Release ^
    -D CMAKE_INSTALL_PREFIX="%_install_dir%" ^
    -D CMAKE_VERBOSE_MAKEFILE=ON ^
    -D bip3x_BUILD_SHARED_LIBS=ON ^
    -D bip3x_BUILD_JNI_BINDINGS=ON ^
    -D bip3x_BUILD_C_BINDINGS=ON ^
    -D bip3x_USE_OPENSSL_RANDOM=ON ^
    -D bip3x_BUILD_TESTS=ON ^
    %SRC_DIR%
  if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

  cmake --build . --config Release
  if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

  cmake --install . --config Release
  if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
cd %SRC_DIR%
endlocal
GOTO :EOF
