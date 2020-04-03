echo %PKG_VERSION% > version.txt
%PYTHON% -m pip install .  -vv
if errorlevel 1 exit 1