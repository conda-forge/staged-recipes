@echo off

nmake LIBPNGDIR="%LIBRARY_PREFIX%" ZLIBDIR="%LIBRARY_PREFIX%"
if errorlevel 1 exit 1
