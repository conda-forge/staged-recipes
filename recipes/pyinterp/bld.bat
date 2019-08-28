%PYTHON% setup.py build
if errorlevel 1 exit 1

%PYTHON% setup.py install
if errorlevel 1 exit 1
