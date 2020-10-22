copy "%RECIPE_DIR%\build-runtime.sh" .
set PREFIX=%PREFIX:\=/%
set SRC_DIR=%SRC_DIR:\=/%
set MSYSTEM=MINGW%ARCH%
set MSYS2_PATH_TYPE=inherit
set CHERE_INVOKING=1
set BUILD_PLATFORM=win-64


bash -lc "./build-runtime.sh"
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

echo F | xcopy "%RECIPE_DIR%\dotnet.cmd" "%PREFIX%\Scripts\dotnet.cmd" /F /Y
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

exit /b 0
