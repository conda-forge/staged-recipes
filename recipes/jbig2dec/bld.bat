@echo on

nmake LIBPNGDIR="%LIBRARY_PREFIX%" ZLIBDIR="%LIBRARY_PREFIX%" @msvc.mak
if errorlevel 1 exit 1
