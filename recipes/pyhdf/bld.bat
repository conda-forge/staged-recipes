set INCLUDE_DIRS=%PREFIX%\include
set LIBRARY_DIRS=%PREFIX%\libs
python setup.py install
if errorlevel 1 exit 1
