@echo on
setlocal EnableExtensions EnableDelayedExpansion
set SHORT_VERSION=%PKG_VERSION:~0,-2%

:: You may not always want this when doing dirty builds (debugging late stage
:: problems, but if debugging configure time issues you probably do want this).
if exist config.cache del config.cache

:: if "%DXSDK_DIR%" == "" (
::   echo You do not appear to have the DirectX SDK installed.  Please get it from
::   echo    https://www.microsoft.com/en-us/download/details.aspx?id=6812
::   echo and try this build again.  If you have installed it, and are still seeing
::   echo this message, please open a new console to refresh your environment variables.
::   exit /b 1
:: )

:: Set each include folder as a include flag to MSVC
pushd %LIBRARY_INC%
for /F "usebackq delims=" %%F in (`dir /b /ad-h`) do (
    set LIBRARY_PATHS=!LIBRARY_PATHS! -I %LIBRARY_INC%\%%F
)
popd
endlocal

:: Make sure jom is picked up
set PATH=%cd%\jom;%PATH%
SET PATH=%cd%\qtbase\bin;%_ROOT%\gnuwin32\bin;%PATH%

:: Set LLVM path in order to build docs
set LLVM_INSTALL_DIR=%PREFIX%\Library

:: Compilation fails due to long path names in the case of angle
:: We create a symlink to the actual folder and then instruct Qt
:: to locate angle under our symlink
mklink /D %cd%\angle %cd%\qtbase\src\3rdparty\angle
set ANGLE_DIR=%cd%\angle

set QT_LIBINFIX=_conda

where perl.exe
if %ERRORLEVEL% neq 0 (
  echo Could not find perl.exe
  exit /b 1
)

:: Support systems with neither capable OpenGL (desktop mode) nor DirectX 11 (ANGLE mode) drivers
:: https://github.com/ContinuumIO/anaconda-issues/issues/9142
if not exist "%LIBRARY_BIN%" mkdir "%LIBRARY_BIN%"
copy opengl32sw\opengl32sw.dll  %LIBRARY_BIN%\opengl32sw.dll
if errorlevel 1 exit /b 1
if not exist %LIBRARY_BIN%\opengl32sw.dll exit /b 1

set OPENGLVER=dynamic

mkdir b
pushd b

:: See http://doc-snapshot.qt-project.org/qt5-5.4/windows-requirements.html
:: this needs to be CALLed due to an exit statement at the end of configure:
:: optimized-tools is necessary for qtlibinfix, otherwise:
:: qtbase/lib/Qt5Bootstrap.prl
:: ends up containing:
:: QMAKE_PRL_TARGET = Qt5Bootstrap.condad.lib
:: for some odd reason.
call "../configure" ^
     -prefix %LIBRARY_PREFIX% ^
     -libdir %LIBRARY_LIB% ^
     -bindir %LIBRARY_BIN% ^
     -headerdir %LIBRARY_INC%\qt ^
     -archdatadir %LIBRARY_PREFIX% ^
     -datadir %LIBRARY_PREFIX% ^
     -optimized-tools ^
     %LIBRARY_PATHS% ^
     -L %LIBRARY_LIB% ^
     -I %LIBRARY_INC% ^
     -confirm-license ^
     -no-fontconfig ^
     -icu ^
     -no-separate-debug-info ^
     -no-warnings-are-errors ^
     -nomake examples ^
     -nomake tests ^
     -no-warnings-are-errors ^
     -skip qtwebengine ^
     -opengl %OPENGLVER% ^
     -opensource ^
     -openssl ^
     -openssl-runtime ^
     -platform win32-msvc ^
     -release ^
     -shared ^
     -qt-freetype ^
     -system-libjpeg ^
     -system-libpng ^
     -system-sqlite ^
     -system-zlib ^
     -plugin-sql-sqlite ^
     -qtlibinfix %QT_LIBINFIX% ^
     -verbose

if %errorlevel% neq 0 exit /b %errorlevel%

:: re-enable echoing which is disabled by configure
echo on

:: To get a much quicker turnaround you can add this: (remember also to add the hat symbol after -plugin-sql-sqlite)
::     -skip %WEBBACKEND% -skip qtwebsockets -skip qtwebchannel -skip qtwayland -skip qtwinextras -skip qtsvg -skip qtsensors ^
::     -skip qtcanvas3d -skip qtconnectivity -skip declarative -skip multimedia -skip qttools

jom
if %errorlevel% neq 0 exit /b %errorlevel%
echo Finished `jom -U release`
jom install
if %errorlevel% neq 0 exit /b %errorlevel%
echo Finished `jom -U install`

if exist %LIBRARY_BIN%\qmake.exe goto ok_qmake_exists
echo Warning %LIBRARY_BIN%\qmake.exe does not exist jom -U install failed, very strange. Copying it from qtbase\bin\qmake.exe
copy qtbase\bin\qmake.exe %LIBRARY_BIN%\qmake.exe
:ok_qmake_exists

popd
pushd qtcharts
%LIBRARY_BIN%\qmake.exe qtcharts.pro PREFIX=%PREFIX%
jom
jom install
popd

:: To rewrite qt.conf contents per conda environment
if not exist %PREFIX%\Scripts mkdir %PREFIX%\Scripts
copy "%RECIPE_DIR%\write_qtconf.bat" "%PREFIX%\Scripts\.qt-post-link.bat"
if %errorlevel% neq 0 exit /b %errorlevel%
