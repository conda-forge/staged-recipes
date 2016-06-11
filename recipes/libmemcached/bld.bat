configure --prefix="%PREFIX%" && make && make install
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%
