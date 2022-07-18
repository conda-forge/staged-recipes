copy "%RECIPE_DIR%\build.sh" .
if %errorlevel% neq 0 exit /b %errorlevel%

set PREFIX=%PREFIX:\=/%
set SRC_DIR=%SRC_DIR:\=/%

bash -lc "./build.sh"
if %errorlevel% neq 0 exit /b %errorlevel%

exit /b 0
