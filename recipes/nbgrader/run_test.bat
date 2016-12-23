cd /D "%SRC_DIR%"

CALL npm install phantomjs-prebuilt
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%

CALL invoke tests --group=python || EXIT /B 1
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%
