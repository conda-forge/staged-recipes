@echo on
SETLOCAL EnableDelayedExpansion


set VC_PATH=x86
if "%ARCH%"=="64" (
   set VC_PATH=x64
)

set MSC_VER=2017

REM ========== This one comes from visual studio 2017
set "VC_VER=141"
set "BT_ROOT=C:\Program Files (x86)\Microsoft Visual Studio\%MSC_VER%\Enterprise"
if not exist "%BT_ROOT%" (
set "BT_ROOT=C:\Program Files (x86)\Microsoft Visual Studio\%MSC_VER%\Community"
)
if not exist "%BT_ROOT%" (
set "BT_ROOT=C:\Program Files (x86)\Microsoft Visual Studio\%MSC_VER%\BuildTools"
)
if not exist "%BT_ROOT%" (
set "BT_ROOT=C:\Program Files (x86)\Microsoft Visual Studio\%MSC_VER%\Professional"
)

set "REDIST_ROOT=%BT_ROOT%\VC\Redist\MSVC\%runtime_version%\%VC_PATH%"
echo "%REDIST_ROOT%"


dir "%BT_ROOT%\VC\Redist\MSVC\"

IF NOT EXIST "%BT_ROOT%\VC\Redist\MSVC\%runtime_version%" (
   echo ============================================================================================
   set "out=!out! Expected vcruntime140.dll version (from conda_build_config.yaml) was %runtime_version%."
   set "out=!out! That version does not appear to be installed. "
   set "out=!out! Please either install the expected VS %MSC_VER% udpate, or update conda_build_config.yaml "
   set "out=!out! to reflect the current value of the installed version.  See %BT_ROOT%\VC\Redist\MSVC\ for installed versions."
   echo !out!
   echo ============================================================================================
   exit 1
   )

robocopy "%REDIST_ROOT%\Microsoft.VC%VC_VER%.CRT" "%LIBRARY_BIN%" *.dll /E
if %ERRORLEVEL% GTR 8 exit 1
robocopy "%REDIST_ROOT%\Microsoft.VC%VC_VER%.CRT" "%PREFIX%" *.dll /E
if %ERRORLEVEL% GTR 8 exit 1
robocopy "%REDIST_ROOT%\Microsoft.VC%VC_VER%.OpenMP" "%LIBRARY_BIN%" *.dll /E
if %ERRORLEVEL% GTR 8 exit 1
robocopy "%REDIST_ROOT%\Microsoft.VC%VC_VER%.OpenMP" "%PREFIX%" *.dll /E
if %ERRORLEVEL% GTR 8 exit 1

REM ========== REQUIRES Win 10 SDK be installed, or files otherwise copied to location below!
robocopy "C:\Program Files (x86)\Windows Kits\10\Redist\ucrt\DLLs\%VC_PATH%"  "%LIBRARY_BIN%" *.dll /E
if %ERRORLEVEL% GEQ 8 exit 1
robocopy "C:\Program Files (x86)\Windows Kits\10\Redist\ucrt\DLLs\%VC_PATH%"  "%PREFIX%" *.dll /E
if %ERRORLEVEL% GEQ 8 exit 1
COPY "C:\Program Files (x86)\Windows Kits\10\Redist\ucrt\DLLs\%VC_PATH%\ucrtbase.dll" "%LIBRARY_BIN%"
COPY "C:\Program Files (x86)\Windows Kits\10\Redist\ucrt\DLLs\%VC_PATH%\ucrtbase.dll" "%PREFIX%"

