:: Disabled cython compilation for now.  Maybe thriftpy eventually supports the cython extensions on windows
:: "%PYTHON%" setup.py build_ext
"%PYTHON%" setup.py install
if errorlevel 1 exit 1
