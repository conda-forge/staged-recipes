if "%ARCH%"=="32" (
set PLATFORM=x86
) else (
set PLATFORM=x64
)

:: build the shell
cl shell.c sqlite3.c -Fesqlite3.exe /DSQLITE_EXPORTS

:: build the dll
cl /DSQLITE_EXPORTS sqlite3.c -link -dll -out:sqlite3.dll

COPY sqlite3.exe %LIBRARY_BIN%\
COPY sqlite3.dll %LIBRARY_BIN%\
COPY sqlite3.lib %LIBRARY_LIB%\
COPY sqlite3.h   %LIBRARY_INC%\
