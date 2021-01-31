@echo on
setlocal

set CL=/I%LIBRARY_PREFIX%\include
set LIB=%LIBRARY_PREFIX%\lib;%LIB%

%PYTHON% -m pip install . -vv
