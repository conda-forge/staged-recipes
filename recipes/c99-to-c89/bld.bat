copy c99wrap.exe %LIBRARY_BIN%\c99wrap.exe
copy c99conv.exe %LIBRARY_BIN%\c99conv.exe
copy makedef %LIBRARY_BIN%\makedef

rem Have to run the test here as cl.exe is only
rem available during building.
c99wrap cl /EP /P %RECIPE_DIR%\unit.c
if errorlevel 1 exit 1
