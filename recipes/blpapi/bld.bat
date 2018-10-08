set BLPAPI_ROOT="blpapi_cpp_windows"
copy blpapi_cpp_3.8.18.1\lib\*64* "%PREFIX%"
if errorlevel 1 exit 1
"%PYTHON%" setup.py install
if errorlevel 1 exit 1
