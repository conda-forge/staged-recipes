@echo on
:: Set env vars that tell distutils to use the compiler that we put on path
SET DISTUTILS_USE_SDK=1
SET MSSdk=1

SET "VS_VERSION=15.0"
SET "VS_MAJOR=15"
SET "VS_YEAR=2017"

set "MSYS2_ARG_CONV_EXCL=/AI;/AL;/OUT;/out"
set "MSYS2_ENV_CONV_EXCL=CL"

:: For Python 3.5+, ensure that we link with the dynamic runtime.  See
:: http://stevedower.id.au/blog/building-for-python-3-5-part-two/ for more info
set "PY_VCRUNTIME_REDIST=%PREFIX%\\bin\\vcruntime140.dll"

set "VSINSTALLDIR=C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\"
if not exist "%VSINSTALLDIR%" (
set "VSINSTALLDIR=C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\"
)
if not exist "%VSINSTALLDIR%" (
set "VSINSTALLDIR=C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\"
)
if not exist "%VSINSTALLDIR%" (
set "VSINSTALLDIR=C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\"
)

IF NOT "%CONDA_BUILD%" == "" (
  set "INCLUDE=%LIBRARY_INC%;%INCLUDE%"
  set "LIB=%LIBRARY_LIB%;%LIB%"
)

:: other things added by install_activate.bat at package build time

