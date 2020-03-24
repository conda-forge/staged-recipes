@echo on

nmake /f msvc.mak LIBPNGDIR=%LIBRARY_LIB% ZLIBDIR=%LIBRARY_LIB%
if errorlevel 1 exit 1

dir
