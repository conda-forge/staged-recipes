
copy "%RECIPE_DIR%\build_windows_mingw-64.sh" .
set PREFIX=%PREFIX:\=/%
set SRC_DIR=%SRC_DIR:\=/%
set MSYSTEM=MINGW%ARCH%
set MSYS2_PATH_TYPE=inherit
set CHERE_INVOKING=1
set BUILD_PLATFORM=win-64


bash -lc "./build_windows_mingw-64.sh"
if %ERRORLEVEL% neq 0 exit /b %ERRORLEVEL%
