
if %ARCH% == 64 (
    set PLATF=x64
	set OUTDIR=Win64
) else (
    set PLATF=Win32
	set OUTDIR=Win32
)

msbuild projects\Win32\VC10\xerces-all\xerces-all.sln /t:all /p:Configuration=Release;Platform=%PLATF%
if errorlevel 1 exit 1

REM implib and DLL
mkdir %PREFIX%\lib
copy Build\%OUTDIR%\VC10\Release\xerces-c_3.lib %PREFIX%\lib\
if errorlevel 1 exit 1
copy Build\%OUTDIR%\VC10\Release\xerces-c_3_1.dll %PREFIX%
if errorlevel 1 exit 1

REM Headers. Must be a better way...
echo .cpp > excludelist.txt
mkdir %PREFIX%\include\xercesc
xcopy /s /exclude:excludelist.txt src\xercesc %PREFIX%\include\xercesc
if errorlevel 1 exit 1
