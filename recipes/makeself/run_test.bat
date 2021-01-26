bash -l %RECIPE_DIR%\run_test.sh
if %errorlevel% neq 0 exit /b %errorlevel%
