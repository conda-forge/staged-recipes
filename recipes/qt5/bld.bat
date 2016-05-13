:: set path to find resources shipped with qt-5
:: see http://doc-snapshot.qt-project.org/qt5-5.4/windows-building.html
set PATH=%SRC_DIR%\qtbase\bin;%SRC_DIR%\gnuwin32\bin;%PATH%
set QMAKESPEC=win32-msvc%VS_YEAR:"=%
set SHORT_VERSION=%PKG_VERSION:~0,-2%

:: NOTE: you must have the DirectX SDK installed for ANGLE to compile:
::    https://www.microsoft.com/en-us/download/details.aspx?id=6812
::    (572 MB, not availabe through Conda)
::   You should also set the DXSDK_DIR environment variable once you have the SDK installed.

curl -LO "http://download.qt.io/community_releases/%SHORT_VERSION%/%PKG_VERSION%/qtwebkit-opensource-src-%PKG_VERSION%.tar.xz"
if errorlevel 1 exit 1
7za x -so qtwebkit-opensource-src-%PKG_VERSION%.tar.xz | 7za x -si -aoa -ttar
if errorlevel 1 exit 1
MOVE qtwebkit-opensource-src-%PKG_VERSION% qtwebkit

:: Install a custom python 27 environment for us, to use in building, but avoid feature activation
conda create -n python27_qt5_build python=2.7

:: make sure we can find ICU and openssl:
set INCLUDE=%PREFIX%\Library\include;%INCLUDE%
set LIB=%LIBRARY_LIB%;%LIB%
set "PATH=%PREFIX%\..\python27_qt5_build;%PREFIX%\..\python27_qt5_build\Scripts;%PREFIX%\..\python27_qt5_build\Library\bin;%PATH%"

set "WSDK8=C:\\Program Files (x86)\\Windows Kits\\8.1"
set "WDK=C:\\WinDDK\\7600.16385.1"
set "INCLUDE=%WSDK8%\Include;%WDK%\inc;%INCLUDE%"
if "%1"=="/x64" goto x64
set "PATH=%WSDK8%\bin\x86;%WDK$%\bin\x86;%PATH%"
set "LIB=%LIB%;%WSDK8%\Lib\winv6.3\um\x86"
goto done
:x64
set "PATH=%WSDK8%\bin\x64;%WDK$%\bin\amd64;%PATH%"
set "LIB=%LIB%;%WSDK8%\Lib\winv6.3\um\x64"
:done

set "GYP_DEFINES=windows_sdk_path=\"%WSDK8%\""
set GYP_MSVS_VERSION=2015
set GYP_GENERATORS=ninja
set GYP_PARALLEL=1
set WDK_DIR="%WDK%"
set WindowsSDKDir="%WSDK8%"

:: make sure we can find sqlite3:
set SQLITE3SRCDIR=%SRC_DIR%\qtbase\src\3rdparty\sqlite

set

:: See http://doc-snapshot.qt-project.org/qt5-5.4/windows-requirements.html

:: this needs to be CALLed due to an exit statement at the end of configure:
CALL configure ^
     -archdatadir %LIBRARY_LIB%\qt5 ^
     -bindir %LIBRARY_BIN%\qt5 ^
     -confirm-license ^
     -datadir %LIBRARY_PREFIX%\share\qt5 ^
     -fontconfig ^
     -headerdir %LIBRARY_INC%\qt5 ^
     -I %LIBRARY_INC% ^
     -L %LIBRARY_LIB% ^
     -icu ^
     -libdir %LIBRARY_LIB%\qt5 ^
     -no-warnings-are-errors ^
     -no-separate-debug-info ^
     -nomake examples ^
     -nomake tests ^
     -opengl dynamic ^
     -opensource ^
     -openssl ^
     -platform win32-msvc%VS_YEAR:"=% ^
     -prefix %LIBRARY_PREFIX% ^
     -release ^
     -shared ^
     -system-libpng ^
     -system-zlib ^
     -system-libjpeg

:: jom is nmake alternative with multicore support, uses all cores by default
jom
jom install

conda remove -n python27_qt5_build -all

:: remove docs, phrasebooks, translations
rmdir %PREFIX%\Library\share\qt5 /s /q

%PYTHON% %RECIPE_DIR%\patch_prefix_files.py
