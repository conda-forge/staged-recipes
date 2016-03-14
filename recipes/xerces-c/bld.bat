
if %ARCH% == 64 (
    set PLATF=x64
    set OUTDIR=Win64
) else (
    set PLATF=Win32
    set OUTDIR=Win32
)

if %PY3K% == 1 (
    set VCVERSION=VC10
) else (
    set VCVERSION=VC9
)

msbuild projects\Win32\%VCVERSION%\xerces-all\xerces-all.sln /t:all /p:Configuration=Release;Platform=%PLATF%
if errorlevel 1 exit 1

REM implib and DLL
copy Build\%OUTDIR%\%VCVERSION%\Release\xerces-c_3.lib %LIBRARY_LIB%
if errorlevel 1 exit 1
copy Build\%OUTDIR%\%VCVERSION%\Release\xerces-c_3_1.dll %LIBRARY_BIN%
if errorlevel 1 exit 1

REM Headers.
echo .cpp > excludelist.txt
mkdir %LIBRARY_INC%\xercesc
xcopy /s /exclude:excludelist.txt src\xercesc %LIBRARY_INC%\xercesc
if errorlevel 1 exit 1
