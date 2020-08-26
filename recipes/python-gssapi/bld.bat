setlocal EnableDelayedExpansion

echo on

set GSSAPI_LINKER_ARGS=-l%LIBRARY_LIB%\comerr64.lib -l%LIBRARY_LIB%\gssapi64.lib -l%LIBRARY_LIB%\k5sprt64.lib -l%LIBRARY_LIB%\kfwlogon.lib -l%LIBRARY_LIB%\krb5_64.lib -l%LIBRARY_LIB%\krbcc64.lib -l%LIBRARY_LIB%\leashw64.lib -l%LIBRARY_LIB%\xpprof64.lib
set GSSAPI_COMPILER_ARGS=-DMS_WIN64
set GSSAPI_MAIN_LIB=%LIBRARY_BIN%\gssapi64.dll

:: %PYTHON% -m pip install . -vv
%PYTHON% setup.py build
%PYTHON% setup.py install

