python setup.py install
if errorlevel 1 exit 1

move examples %EXAMPLES%
if errorlevel 1 exit 1

del %SCRIPTS%\*.exe
if errorlevel 1 exit 1
