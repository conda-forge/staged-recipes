@echo off

set "build_dir=%SRC_DIR%\build-release"
set "pre_install_dir=%SRC_DIR%\pre-install"
set "test_release_dir=%SRC_DIR%\test-release"

call :configBuildInstall "%build_dir%" "%pre_install_dir%"
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

:: Remove 'toolbox' files
powershell -Command "& { Get-ChildItem -Path '%pre_install_dir%' -Recurse -Filter '*toolbox*' | Remove-Item -Force -Recurse }"
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

:: Prepare test area
powershell -Command "& { New-Item -Path '%test_release_dir%' -ItemType Directory -Force | Out-Null }"
powershell -Command "& { Copy-Item -Path (Join-Path '%build_dir%' 'bin') -Destination '%test_release_dir%' -Recurse }"
powershell -Command "& { Get-ChildItem -Path '%pre_install_dir%' -Recurse -Filter '*[Gg][Tt]est*' | ForEach-Object { tar -cf - $_.FullName | tar -xf - -C '%test_release_dir%'; Remove-Item $_.FullName -Force -Recurse } }"
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

:: Transfer pre-install to PREFIX
cd "%pre_install_dir%"
powershell -Command "& { Copy-Item -Path '.\*' -Destination $env:PREFIX -Recurse -Force }"
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
cd "%SRC_DIR%"

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
