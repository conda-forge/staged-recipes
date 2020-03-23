@echo on

nmake LIBPNGDIR=%PREFIX%\Library ZLIBDIR=%PREFIX%\Library  @msvc.mak
if errorlevel 1 exit 1
