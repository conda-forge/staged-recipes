python setup.py install
if errorlevel 1 exit 1

copy %SRC_DIR%\cwp.py %PREFIX%\
if errorlevel 1 exit 1
