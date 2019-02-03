set SLN_FILE=OfficeToPDF.sln
set SLN_CFG=Release
if "%ARCH%"=="32" (set SLN_PLAT=Win32) else (set SLN_PLAT=x64)

REM Build step
msbuild "%SLN_FILE%" /p:Configuration=%SLN_CFG%,Platform=%SLN_PLAT%,PlatformToolset=v140
if errorlevel 1 exit 1

REM Copy the binaries
copy OfficeToPDF\bin\%SLN_PLAT%\%SLN_CFG%\* %LIBRARY_BIN%
