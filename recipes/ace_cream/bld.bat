:: gfortran env is set MINGW_PREFIX
:: conda root path is set CONDA_PREFIX
:: VS2015 tools are available
:: current working directory is build directory
:: @echo off
if not defined MINGW_PREFIX set MINGW_PREFIX=E:\MINGW64
:: add MINGW_PREFIX and CONDA_PREFIX to environment variable
set path=%path%;%MINGW_PREFIX%\mingw64\bin;
:: in conda-build environment PYTHON is defined
"%PYTHON%" setup.py install
if errorlevel 1 exit 1
