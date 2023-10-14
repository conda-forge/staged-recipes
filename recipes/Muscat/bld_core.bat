%python% setup.py build_clib 
if errorlevel 1 exit 1 
%python% -m pip install --no-deps . -vv 
if errorlevel 1 exit 1
