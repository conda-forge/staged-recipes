
if %ARCH% == 64 (
    set PLATF=x64
	set OUTDIR=Win64
) else (
    set PLATF=Win32
	set OUTDIR=Win32
)

set XERCESVC=VC%VS_MAJOR%
set XERCESSOLUTION=projects\Win32\%XERCESVC%\xerces-all\xerces-all.sln

if not exist %XERCESSOLUTION% (
    REM see https://github.com/conda/conda-build/wiki/Windows-recipe-patterns#updating-older-sln-files
    REM Upgrade the VC9 version - got weird errors with VC12
    REM I should be able to update XERCESVC above, but it doesn't work for me !?
    devenv.exe projects\Win32\VC9\xerces-all\xerces-all.sln /Upgrade
    if errorlevel 1 exit 1
    msbuild projects\Win32\VC9\xerces-all\xerces-all.sln /t:XercesLib /p:Configuration=Release;Platform=%PLATF%
    if errorlevel 1 exit 1

    REM implib and DLL - this method puts it in a different place?!
    copy projects\Win32\VC9\xerces-all\XercesLib\%OUTDIR%\xerces-c_3.lib %LIBRARY_LIB%
    if errorlevel 1 exit 1
    copy projects\Win32\VC9\xerces-all\XercesLib\%OUTDIR%\xerces-c_3_1.dll %LIBRARY_BIN%
    if errorlevel 1 exit 1
) else (
    msbuild %XERCESSOLUTION% /t:XercesLib /p:Configuration=Release;Platform=%PLATF%
    if errorlevel 1 exit 1

    REM implib and DLL
    copy Build\%OUTDIR%\%XERCESVC%\Release\xerces-c_3.lib %LIBRARY_LIB%
    if errorlevel 1 exit 1
    copy Build\%OUTDIR%\%XERCESVC%\Release\xerces-c_3_1.dll %LIBRARY_BIN%
    if errorlevel 1 exit 1
)

REM Headers. Must be a better way...
echo .cpp > excludelist.txt
echo .c >> excludelist.txt
mkdir %LIBRARY_INC%\xercesc
xcopy /s /exclude:excludelist.txt src\xercesc %LIBRARY_INC%\xercesc
if errorlevel 1 exit 1
