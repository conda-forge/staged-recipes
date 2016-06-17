setlocal enabledelayedexpansion
set MSC_VER=10
set VC_PATH=x86
if "%ARCH%"=="64" (
   set VC_PATH=x64
)

FOR /F "usebackq tokens=3*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\Software\WOW6432Node\Microsoft\DevDiv\VS\Servicing\%MSC_VER%.0" /v SP`) DO (
    set SP=%%A
    )

if not "%SP%" == "0x1" (
   echo VS 2010 Service Pack 1 needs to be installed.  Exiting.
   exit 1
)

robocopy "C:\Program Files (x86)\Microsoft Visual Studio %MSC_VER%.0\VC\redist\%VC_PATH%\Microsoft.VC%MSC_VER%0.CRT" "%LIBRARY_BIN%" *.dll /E
robocopy "C:\Program Files (x86)\Microsoft Visual Studio %MSC_VER%.0\VC\redist\%VC_PATH%\Microsoft.VC%MSC_VER%0.CRT" "%PREFIX%" *.dll /E
robocopy "C:\Program Files (x86)\Microsoft Visual Studio %MSC_VER%.0\VC\redist\%VC_PATH%\Microsoft.VC%MSC_VER%0.OpenMP" "%LIBRARY_BIN%" *.dll /E
robocopy "C:\Program Files (x86)\Microsoft Visual Studio %MSC_VER%.0\VC\redist\%VC_PATH%\Microsoft.VC%MSC_VER%0.OpenMP" "%PREFIX%" *.dll /E
if %ERRORLEVEL% LSS 8 exit 0
