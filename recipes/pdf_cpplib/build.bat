@echo off
setlocal EnableExtensions

if not defined PREFIX set "PREFIX=%LIBRARY_PREFIX%"

mkdir "%PREFIX%\include\pdf_cpplib\include" 2>nul
copy /Y pdf_cpplib\include\*.hpp "%PREFIX%\include\pdf_cpplib\include\"
if errorlevel 1 exit /b 1

mkdir "%PREFIX%\lib\pkgconfig" 2>nul
(
echo prefix=%PREFIX%
echo includedir=${prefix}/include
echo Name: pdf_cpplib
echo Description: C++ probability distribution helpers used by flowy
echo Version: 0.1.0
echo Cflags: -I${includedir}
) > "%PREFIX%\lib\pkgconfig\pdf_cpplib.pc"
if errorlevel 1 exit /b 1

exit /b 0
