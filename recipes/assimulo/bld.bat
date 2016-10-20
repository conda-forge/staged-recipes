
"%PYTHON%" setup.py build --sundials-home=%LIBRARY_PREFIX%
if errorlevel 1 exit 1

"%PYTHON%" setup.py install --sundials-home=%LIBRARY_PREFIX%
if errorlevel 1 exit 1
