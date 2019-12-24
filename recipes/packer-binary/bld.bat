setlocal enableextensions enabledelayedexpansion


echo F | xcopy %SRC_DIR%\packer.exe %PREFIX%\bin\packer.exe /F /Y
if %ERRORLEVEL% NEQ 0 goto FAIL

exit /B 0

:FAIL
echo Command failed with ERRORLEVEL %ERRORLEVEL%
exit /B 1