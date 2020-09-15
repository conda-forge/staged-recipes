set "INCLUDE=%INCLUDE%;%LIBRARY_INC%\OpenEXR"
%PYTHON% -m pip install . -vv
if errorlevel 1 exit 1
