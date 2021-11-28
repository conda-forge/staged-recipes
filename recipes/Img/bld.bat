if "%ARCH%"=="32" (
   set MACHINE="IX86"
   :: A different SDK is needed when build with VS 2017 and 2015
   :: http://wiki.tcl.tk/54819
   if "%VS_MAJOR%"=="14" (
    echo "Switching SDK versions"
    call "%VS140COMNTOOLS%..\..\VC\vcvarsall.bat" x86 10.0.15063.0
   )
) else (
  set MACHINE="AMD64"
  :: A different SDK is needed when build with VS 2017 and 2015
  :: http://wiki.tcl.tk/54819
  if "%VS_MAJOR%"=="14" (
    echo "Switching SDK versions"
    call "%VS140COMNTOOLS%..\..\VC\vcvarsall.bat" x64 10.0.15063.0
  )
)

rem pushd tcl_source\win
rem nmake -f makefile.vc INSTALLDIR=%LIBRARY_PREFIX% MACHINE=%MACHINE% release
rem nmake -f makefile.vc INSTALLDIR=%LIBRARY_PREFIX% MACHINE=%MACHINE% install
rem if %ERRORLEVEL% GTR 0 exit 1
rem popd

REM Required for having tmschema.h accessible.  Newer VS versions do not include this.
REM If you don't have this path, you are missing the Windows 7 SDK.  Please install this.
REM   NOTE: Later SDKs remove tmschema.h.  It really is necessary to use the Win 7 SDK.
rem set INCLUDE=%INCLUDE%;c:\Program Files (x86)\Microsoft SDKs\Windows\v7.1A\Include

:: Tk build

rem pushd tk_source\win
rem nmake -f makefile.vc INSTALLDIR=%LIBRARY_PREFIX% MACHINE=%MACHINE% TCLDIR=..\..\tcl_source release
rem nmake -f makefile.vc INSTALLDIR=%LIBRARY_PREFIX% MACHINE=%MACHINE% TCLDIR=..\..\tcl_source install
rem rem if %ERRORLEVEL% GTR 0 exit 1

:: Make sure that `wish` can be called without the version info.
rem copy %LIBRARY_PREFIX%\bin\wish86t.exe %LIBRARY_PREFIX%\bin\wish.exe
rem copy %LIBRARY_PREFIX%\bin\tclsh86t.exe %LIBRARY_PREFIX%\bin\tclsh.exe

:: No `t` version of wish86.exe
rem copy %LIBRARY_PREFIX%\bin\wish86t.exe %LIBRARY_PREFIX%\bin\wish86.exe
rem copy %LIBRARY_PREFIX%\bin\tclsh86t.exe %LIBRARY_PREFIX%\bin\tclsh86.exe
rem popd

echo "tkimg building"
rem cd %PREFIX%\Library\lib\
rem dir
copy %RECIPE_DIR%\build.sh build.sh
sh build.sh

rem set TCL_LIB_PATH=%PREFIX%\Library\lib\%PKG_NAME%%PKG_VERSION%
rem mkdir %TCL_LIB_PATH% || exit /b 1
rem xcopy ImgBinary\*.* %TCL_LIB_PATH%\ || exit /b 1
rem xcopy ImgSource\license.terms %TCL_LIB_PATH%\ || exit /b 1
