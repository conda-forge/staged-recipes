setlocal EnableDelayedExpansion

echo on

set GSSAPI_LINKER_ARGS=-lgssapi64.lib
set GSSAPI_COMPILER_ARGS=-DMS_WIN64
set GSSAPI_MAIN_LIB=%LIBRARY_BIN%\gssapi64.dll

:: %PYTHON% -m pip install . -vv
%PYTHON% setup.py build
%PYTHON% setup.py install

