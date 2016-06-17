set VC_PATH=x86
if "%ARCH%"=="64" (
   set VC_PATH=x64
)

set MSC_VER=14

:: This should always be present for VC installed with VS.  Not sure about VC installed with Visual C++ Build Tools 2015
FOR /F "usebackq tokens=3*" %%A IN (`REG QUERY "HKEY_LOCAL_MACHINE\Software\Microsoft\DevDiv\VC\Servicing\14.0\IDE.x64" /v UpdateVersion`) DO (
    set SP=%%A
    )

if not "%SP%" == "%PKG_VERSION%" (
   echo "Version detected from registry: %SP%"
   echo    "does not match version of package being built (%PKG_VERSION%)"
   echo "Do you have current updates for VS 2015 installed?"
   exit 1
)


REM ========== REQUIRES Win 10 SDK be installed, or files otherwise copied to location below!
robocopy "C:\Program Files (x86)\Windows Kits\10\Redist\ucrt\DLLs\%VC_PATH%"  "%LIBRARY_BIN%" *.dll /E
robocopy "C:\Program Files (x86)\Windows Kits\10\Redist\ucrt\DLLs\%VC_PATH%"  "%PREFIX%" *.dll /E
if %ERRORLEVEL% GEQ 8 exit 1
REM ========== This one comes from visual studio 2015
robocopy "C:\Program Files (x86)\Microsoft Visual Studio %MSC_VER%.0\VC\redist\%VC_PATH%\Microsoft.VC%MSC_VER%0.CRT" "%LIBRARY_BIN%" *.dll /E
robocopy "C:\Program Files (x86)\Microsoft Visual Studio %MSC_VER%.0\VC\redist\%VC_PATH%\Microsoft.VC%MSC_VER%0.CRT" "%PREFIX%" *.dll /E
robocopy "C:\Program Files (x86)\Microsoft Visual Studio %MSC_VER%.0\VC\redist\%VC_PATH%\Microsoft.VC%MSC_VER%0.OpenMP" "%LIBRARY_BIN%" *.dll /E
robocopy "C:\Program Files (x86)\Microsoft Visual Studio %MSC_VER%.0\VC\redist\%VC_PATH%\Microsoft.VC%MSC_VER%0.OpenMP" "%PREFIX%" *.dll /E
if %ERRORLEVEL% LSS 8 exit 0
