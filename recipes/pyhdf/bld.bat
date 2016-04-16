set LIBRARY_DIRS=%LIBRARY_BIN%
set INCLUDE_DIRS=%LIBRARY_INC%

"%PYTHON%" setup.py install --single-version-externally-managed --record record.txt
if errorlevel 1 exit 1
