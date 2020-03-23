@echo on

nmake LIBPNGDIR=%LIBRARY_LIB% ZLIBDIR=%LIBRARY_LIB%  @msvc.mak
if errorlevel 1 exit 1
