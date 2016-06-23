python setup.py install
if errorlevel 1 exit 1

del %SCRIPTS%\enaml-run.exe*
if errorlevel 1 exit 1
