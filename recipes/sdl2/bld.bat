<<<<<<< 4dcc1e6b3fd17bc5e5e3159867de152dc96da281
<<<<<<< d8b9f439be1c30a164e0c44628b4366a0ef909d6
@echo off
:: MSVC library for Python 2.7 is not found automaticaly if it is 
:: installed in the user's AppData folder. Add it to PATH
setlocal EnableDelayedExpansion

if "%PY_VER%"=="2.7" (
	set VC9DIR=%LOCALAPPDATA%\Programs\Common\Microsoft\Visual C++ for Python\9.0
	IF EXIST !VC9DIR! ( 
		set PATH=!VC9DIR!;"%PATH%"
		if %ARCH% == 32 call vcvarsall.bat x86
		if %ARCH% == 64 call vcvarsall.bat amd64
		:: vcvarsall does something strange with PATH, preventing xcopy to be found later. Fix this
		set PATH=!PATH!;%SYSTEMROOT%\system32
	)
)
if errorlevel 1 exit 1

:: Go to the source folder
cd %SRC_DIR%

nmake
if errorlevel 1 exit 1

nmake install
=======
@echo off
:: MSVC library for Python 2.7 is not found automaticaly if it is 
:: installed in the user's AppData folder. Add it to PATH
setlocal EnableDelayedExpansion

if "%PY_VER%"=="2.7" (
	set VC9DIR="%LOCALAPPDATA%\Programs\Common\Microsoft\Visual C++ for Python\9.0"
	set DXSDK_DIR="%programfiles(x86)%\Microsoft SDKs\Windows\v7.1A"
	IF EXIST !VC9DIR! ( 
		:: set PATH=!VC9DIR!;"%PATH%"
		if %ARCH% == 32 set VC_ARCH=x86
		if %ARCH% == 64 set VC_ARCH=amd64
		call !VC9DIR!\vcvarsall.bat !VC_ARCH!
		:: vcvarsall does something strange with PATH, preventing xcopy to be found later. Fix this
		:: set PATH=!PATH!;%SYSTEMROOT%\system32
	)
)
if errorlevel 1 exit 1

:: Go to the source folder
cd %SRC_DIR%
mkdir build
cd build

echo "DIRECTX at %DXSDK_DIR%, Yo!"

call %LIBRARY_BIN%\cmake -G "NMake Makefiles" -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" -DCMAKE_BUILD_TYPE:STRING=Release .. 
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
>>>>>>> Update recipes for windows
=======
:: MSVC library for Python 2.7 is not found automaticaly if it is 
:: installed in the user's AppData folder. Add it to PATH
setlocal EnableDelayedExpansion

set TARGET=Release

:: When installing Visual C++ compiler tools for Python 2.7, all files are placed in the users AppData folder
:: conda-bld tries to call vcvarsall at its classic location, which of course fails, so we have to call it from its
:: new location in the the users appdata folder manually, but only if this folder exists of course.
if "%PY_VER%"=="2.7" (
	set VC9DIR="%LOCALAPPDATA%\Programs\Common\Microsoft\Visual C++ for Python\9.0"
	:: set DXSDK_DIR="%programfiles(x86)%\Microsoft SDKs\Windows\v7.1A" :: Doesn't really work, only finds directx partially
	IF EXIST !VC9DIR! ( 
		if %ARCH% == 32 set VC_ARCH=x86
		if %ARCH% == 64 set VC_ARCH=amd64
		call !VC9DIR!\vcvarsall.bat !VC_ARCH!
	)
	set DIRECTX_FLAG="-DDIRECTX=OFF "
	if %ARCH% == 64 set TARGET=Debug
)
if errorlevel 1 exit 1

:: Go to the source folder
cd %SRC_DIR%
mkdir build
cd build

call %LIBRARY_BIN%\cmake -G "NMake Makefiles" -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" -DCMAKE_BUILD_TYPE:STRING=!TARGET! !DIRECTX_FLAG! .. 
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
>>>>>>> Builds working on all Windows options
if errorlevel 1 exit 1