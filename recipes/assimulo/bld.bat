
"%PYTHON%" setup.py install --sundials-home=%LIBRARY_PREFIX%
if errorlevel 1 exit 1
