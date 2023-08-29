rem %PYTHON% -m pip install . -vvv --upgrade pip setuptools wheel
%PYTHON% setup.py install
if errorlevel 1 exit /b 1
