FOR /F "delims=" %%i IN ('cygpath.exe -m "%LIBRARY_PREFIX%"') DO set "LIBRARY_PREFIX_M=%%i"
set "CPPFLAGS=%CPPFLAGS% -I%LIBRARY_PREFIX_M%/include/OpenEXR"
%PYTHON% -m pip install . -vv
if errorlevel 1 exit 1
