set HOME="%CD%"

bash -lc "configure --without-docs"
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%

bash -lc "make"
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%

bash -lc "make install"
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%
