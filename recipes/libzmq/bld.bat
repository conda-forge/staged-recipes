:: @echo off
:: Configure CMake in build directory
call :configBuildInstall "%SRC_DIR%\build-release" "%PREFIX%"
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

:: Exit main script
GOTO :EOF

:: --- Functions ---

:configBuildInstall
setlocal
set "_build_dir=%~1"
set "_install_dir=%~2"

mkdir %_build_dir%
cd %_build_dir%
  set "_install_dir=%_install_dir:\=\\%"

  cmake %CMAKE_ARGS% ^
    -G "Ninja" ^
    -Wno-dev
    -D CMAKE_BUILD_TYPE=Release ^
    -D BUILD_STATIC=OFF ^
    -D CMAKE_INSTALL_PREFIX="%_install_dir%" ^
    %SRC_DIR%
  if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

  cmake --build . --config Release
  if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

  cmake --install . --config Release
  if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
cd %SRC_DIR%
endlocal
GOTO :EOF
