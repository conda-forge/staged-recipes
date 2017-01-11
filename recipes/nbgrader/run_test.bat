CALL npm install phantomjs-prebuilt || EXIT /B 1
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%

CALL invoke tests --group=python || EXIT /B 1
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%
