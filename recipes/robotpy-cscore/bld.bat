@echo on
setlocal

set CL=/I%LIBRARY_PREFIX%\include
set LIB=%LIBRARY_PREFIX%\lib

%PYTHON% -m pip install . -vv
