@echo on
bash "%RECIPE_DIR%\build.sh"
if errorlevel 1 exit /b 1
