REM seems to find _build, still
rmdir /s /q "%PREFIX%\share\jupyter\kernels"

cd /D "%SRC_DIR%"

CALL npm install || EXIT /B 1
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%

CALL npm run test || EXIT /B 1
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%
