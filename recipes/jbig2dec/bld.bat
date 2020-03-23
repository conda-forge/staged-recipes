@echo off
setlocal EnableDelayedExpansion

nmake LIBPNGDIR="%LIBRARY_PREFIX%" ZLIBDIR="%LIBRARY_PREFIX%" all
if errorlevel 1 exit 1
