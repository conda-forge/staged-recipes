@echo on

call "%RECIPE_DIR%\build-wamr.bat" interp
if errorlevel 1 exit /b 1
