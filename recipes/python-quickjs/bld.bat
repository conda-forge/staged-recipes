"%PYTHON%" setup.py build -c mingw32
"%PYTHON%" setup.py install
IF %ERRORLEVEL% NEQ 0 EXIT /B %ERRORLEVEL%
