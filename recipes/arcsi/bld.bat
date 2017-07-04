
%PYTHON% setup.py install
if errorlevel 1 exit 1

REM copy over batch file that calls the python on the path
REM and runs arcsi.py wih the command line params given
copy %RECIPE_DIR%\arcsi.py.bat %SCRIPTS%\
if errorlevel 1 exit 1
