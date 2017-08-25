"%PYTHON%" setup.py install
if errorlevel 1 exit 1

py.test
if errorlevel 1 exit 1
