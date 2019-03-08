CD einsteinpy_build
IF errorlevel 1 EXIT 1
py.test -vv
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%
