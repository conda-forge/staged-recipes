:: gfortran env is set MINGW_PREFIX
:: conda root path is set by CONDA_PREFIX
if defined MINGW_PREFIX goto skip_ev
if defined APPVEYOR (set MINGW_PREFIX=C:\mingw-w64\x86_64-7.3.0-posix-seh-rt_v5-rev0) else (set MINGW_PREFIX=E:\MINGW64)
:skip_ev
:: add MINGW_PREFIX and CONDA_PREFIX to environment variable
set path=%path%;%MINGW_PREFIX%\mingw64\bin;
"%PYTHON%" -m pip install . --no-deps --ignore-installed
if errorlevel 1 exit 1
