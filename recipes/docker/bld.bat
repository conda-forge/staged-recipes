setlocal enableextensions enabledelayedexpansion


xcopy %SRC_DIR%\docker %PREFIX%\Library\docker\ /E /F /Y
if %ERRORLEVEL% NEQ 0 goto FAIL

echo F | xcopy %RECIPE_DIR%\docker.cmd %PREFIX%\Scripts\docker.cmd /F /Y
if %ERRORLEVEL% NEQ 0 goto FAIL

exit /B 0

:FAIL
echo Command failed with ERRORLEVEL %ERRORLEVEL%
exit /B 1