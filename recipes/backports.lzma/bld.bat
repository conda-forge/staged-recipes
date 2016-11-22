%PYTHON% setup.py build_ext -I%LIBRARY_INCLUDE% -L%LIBRARY_LIB%
if errorlevel 1 exit 1

%PYTHON% setup.py install --record record.txt
if errorlevel 1 exit 1
