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
if errorlevel 1 exit 1