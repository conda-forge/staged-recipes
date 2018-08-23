:: gfortran env is set MINGW_PREFIX
:: conda root path is set CONDA_PREFIX
:: VS2015 tools are available
:: current working directory is build directory
:: @echo off
if defined MINGW_PREFIX goto skip_ev
if defined APPVEYOR (set MINGW_PREFIX=C:\mingw-w64\x86_64-7.3.0-posix-seh-rt_v5-rev0) else (set MINGW_PREFIX=E:\MINGW64)
:skip_ev
:: add MINGW_PREFIX and CONDA_PREFIX to environment variable
set path=%path%;%MINGW_PREFIX%\mingw64\bin;
:: in conda-build environment PYTHON is defined
"%PYTHON%" setup.py install
if errorlevel 1 exit 1
