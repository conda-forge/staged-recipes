copy "%RECIPE_DIR%\build-sdk.sh" .
set PREFIX=%PREFIX:\=/%
set SRC_DIR=%SRC_DIR:\=/%
set MSYSTEM=MINGW%ARCH%
set MSYS2_PATH_TYPE=inherit
set CHERE_INVOKING=1
set BUILD_PLATFORM=win-64


bash -lc "./build-sdk.sh"
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%

exit /b 0
