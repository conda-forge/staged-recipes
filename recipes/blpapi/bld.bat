set BLPAPI_ROOT="."
copy "%BLPAPI_ROOT%"\lib\ "%PREFIX%"\lib\
if errorlevel 1 exit 1
"%PYTHON%" setup.py install
if errorlevel 1 exit 1
