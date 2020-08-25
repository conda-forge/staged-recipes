setlocal EnableDelayedExpansion


set GSSAPI_LINKER_ARGS=-L%PREFIX%\Library\lib %PREFIX%\Library\lib\comerr64.lib %PREFIX%\Library\lib\gssapi64.lib %PREFIX%\Library\lib\k5sprt64.lib %PREFIX%\Library\lib\kfwlogon.lib %PREFIX%\Library\lib\krb5_64.lib %PREFIX%\Library\lib\krbcc64.lib %PREFIX%\Library\lib\leashw64.lib %PREFIX%\Library\lib\xpprof64.lib
set GSSAPI_COMPILER_ARGS=-DMS_WIN64 -I%PREFIX%\Library\include


%PYTHON% -m pip install . -vv

