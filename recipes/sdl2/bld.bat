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
if errorlevel 1 exit 1