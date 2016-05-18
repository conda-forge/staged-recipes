if "%ARCH%"=="32" (
   set MACHINE="IX86"
) else (
  set MACHINE="AMD64"
)

:: Get the major minor version info (e.g. `8_5`) so it can be used in the URL.
python -c "import os; print('_'.join(os.environ['PKG_VERSION'].split('.')[:2]))" > temp.txt
set /p MAJ_MIN_VER=<temp.txt

curl -L -o tcl%PKG_VERSION%.tar.gz "ftp://ftp.tcl.tk/pub/tcl/tcl%MAJ_MIN_VER%/tcl%PKG_VERSION%-src.tar.gz"
curl -L -o tk%PKG_VERSION%.tar.gz "ftp://ftp.tcl.tk/pub/tcl/tcl%MAJ_MIN_VER%/tk%PKG_VERSION%-src.tar.gz"

7za x -so tcl%PKG_VERSION%.tar.gz | 7za x -si -aoa -ttar
7za x -so tk%PKG_VERSION%.tar.gz | 7za x -si -aoa -ttar

cd tcl%PKG_VERSION%\win
nmake -f makefile.vc all install INSTALLDIR=%LIBRARY_PREFIX% MACHINE=%MACHINE%
if %ERRORLEVEL% GTR 0 exit 1

REM Required for having tmschema.h accessible.  Newer VS versions do not include this.
REM If you don't have this path, you are missing the Windows 7 SDK.  Please install this.
REM   NOTE: Later SDKs remove tmschema.h.  It really is necessary to use the Win 7 SDK.
set INCLUDE=%INCLUDE%;c:\Program Files (x86)\Microsoft SDKs\Windows\v7.1A\Include


cd ..\..\tk%PKG_VERSION%\win
nmake -f makefile.vc all install INSTALLDIR=%LIBRARY_PREFIX% MACHINE=%MACHINE% TCLDIR=..\..\tcl%PKG_VERSION%
if %ERRORLEVEL% GTR 0 exit 1

:: Change the major minor version info so that it can be used with the exe.
python -c "import os; print(''.join(os.environ['PKG_VERSION'].split('.')[:2]))" > temp.txt
set /p MAJ_MIN_VER=<temp.txt

:: Make sure that `wish` can be called without the version info.
copy %LIBRARY_PREFIX%\bin\wish%MAJ_MIN_VER%.exe %LIBRARY_PREFIX%\bin\wish.exe
