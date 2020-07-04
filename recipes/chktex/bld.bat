bash -lc "./configure --prefix=%PREFIX% --disable-pcre "
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%

bash -lc "make chktex"
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%

bash -lc "make check"
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%

bash -lc "make install"
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%

bash -lc "make test"
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%
