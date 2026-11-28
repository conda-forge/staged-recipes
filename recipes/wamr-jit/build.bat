@echo on

call "%RECIPE_DIR%\..\wamr\build-wamr.bat" jit
if errorlevel 1 exit /b 1
