:: seems to find _build, still
cd /D "%SRC_DIR%"

:: yeah, this is really dirty. but we're testing lots of conda...
conda clean --lock

CALL npm install || EXIT /B 1
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%

CALL npm run test || EXIT /B 1
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%
