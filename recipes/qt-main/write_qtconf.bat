@echo off
setlocal enabledelayedexpansion
:: This file should be run after installing the qt package into any
:: environment.  It makes it so Qt knows where to look for includes and
:: libs.  This script is copied in bld.bat to the post-link script for qt,
:: which means it is run after the Qt package gets linked, and sets up
:: the correct path for whatever Conda env you install Qt to.
pushd "%~dp0\..\"
set "FORWARD_SLASHED_PREFIX=%CD:\=/%"
if not exist "%CD%\Library" mkdir "%CD%\Library"
if not exist "%CD%\Library\bin" mkdir "%CD%\Library\bin"
echo [Paths] > "%CD%\Library\bin\qt.conf"
echo Prefix = %FORWARD_SLASHED_PREFIX%/Library>> "%CD%\Library\bin\qt.conf"
echo Binaries = %FORWARD_SLASHED_PREFIX%/Library/bin>> "%CD%\Library\bin\qt.conf"
echo Libraries = %FORWARD_SLASHED_PREFIX%/Library/lib>> "%CD%\Library\bin\qt.conf"
echo Headers = %FORWARD_SLASHED_PREFIX%/Library/include/qt>> "%CD%\Library\bin\qt.conf"
:: Qt seems to not bother setting QMAKE_SPEC nor QMAKE_XSPEC these days on Windows.
echo TargetSpec = win32-msvc>> "%CD%\Library\bin\qt.conf"
echo HostSpec = win32-msvc>> "%CD%\Library\bin\qt.conf"
:: Some things go looking in the prefix root (pyqt, for example)
copy "%CD%\Library\bin\qt.conf" "%CD%\qt.conf"
@echo on
