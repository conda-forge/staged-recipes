<<<<<<< 2bd2c7b00e11131cb515d21059ce413d1bb176c0
<<<<<<< 4ef3fb651e303190c46024d569ba4d51ed8e56b1
<<<<<<< b657e082ae049bab344fec045cd14e26624c43c6
<<<<<<< c04f55e22b709b6a3d03f117327e36556a4dfdb6
<<<<<<< 02b6fe0879fe9244ee89d48d92b984bad7d25a19
<<<<<<< b02e32cd84c6d76444a8171d41c5685fa3113bdb
<<<<<<< d50847f97545e33546033e6e5b9282d8edce6d59
<<<<<<< cf4e26dca459cde6aa9356130c45a09ddda323bf
<<<<<<< 92a665ffb977d4bd76d869b79ddcc388e3fdd6ae
<<<<<<< c08e6ad2eddde5c6d6fe77699c964c456647f566
<<<<<<< b8edd9fba35b57d5808b416fc2f303e8fa3e9b52
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
=======
:: MSVC library for Python 2.7 is not found automaticaly if it is 
:: installed in the user's AppData folder. Add it to PATH
setlocal EnableDelayedExpansion

set TARGET=Release
:: Set target back to Debug for 64-bits builds with VS2008 and VS2010
if %VS_MAJOR% LSS 14 (
	if %ARCH% == 64 (
		set TARGET=Debug
	)
)

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
>>>>>>> add patch req., add autoconf, fix win target
=======
:: MSVC library for Python 2.7 is not found automaticaly if it is 
:: installed in the user's AppData folder. Add it to PATH
setlocal EnableDelayedExpansion

set TARGET=Release
:: Set target back to Debug for 64-bits builds with VS2008 and VS2010
if %VS_MAJOR% LSS 14 (
	if %ARCH% == 64 (
		set TARGET=Debug
	)
)

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
	set DIRECTX_FLAG="-DDIRECTX=OFF"
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
>>>>>>> small commit to restart builds
=======
:: MSVC library for Python 2.7 is not found automaticaly if it is 
:: installed in the user's AppData folder. Add it to PATH
setlocal EnableDelayedExpansion

set TARGET=Release
:: Set target back to Debug for 64-bits builds with VS2008 and VS2010
if %VS_MAJOR% LSS 14 (
	if %ARCH% == 64 (
		set TARGET=None
	)
)

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
	set DIRECTX_FLAG="-DDIRECTX=OFF"
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
>>>>>>> Change target from Debug to None
=======
:: MSVC library for Python 2.7 is not found automaticaly if it is 
:: installed in the user's AppData folder. Add it to PATH
setlocal EnableDelayedExpansion

set TARGET=Release
:: Set target back to Debug for 64-bits builds with VS2008 and VS2010
if %VS_MAJOR% LSS 14 (
	if %ARCH% == 64 (
		set TARGET=None
	)
)

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
	set DIRECTX_FLAG="-DDIRECTX=OFF"
)
if errorlevel 1 exit 1

:: Go to the source folder
cd %SRC_DIR%
mkdir build
cd build

call %LIBRARY_BIN%\cmake -G "NMake Makefiles" -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" -DCMAKE_BUILD_TYPE:STRING=!TARGET! !DIRECTX_FLAG! .. 
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
>>>>>>> Add cmake_prefix_path
if errorlevel 1 exit 1
=======
setlocal EnableDelayedExpansion

:: Configure for Release (results in smaller .dll file)
set TARGET=Release
:: Set target back to None for 64-bits builds with VS2008 and VS2010
if %VS_MAJOR% LSS 14 (
	if %ARCH% == 64 (
		set TARGET=None
	)
)

:: DirectX being integrated in the windows SDK and not being installed separately
:: confuses good old Visual Studio 2008, so disable DirectX detection durion compilation.
if "%PY_VER%"=="2.7" (
	set DIRECTX_FLAG="-DDIRECTX=OFF"
)
if errorlevel 1 exit 1

:: Make a build folder and change to it.
mkdir build
cd build

:: Configure using the CMakeFiles
call %LIBRARY_BIN%\cmake -G "NMake Makefiles" -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" -DCMAKE_BUILD_TYPE:STRING=!TARGET! !DIRECTX_FLAG! .. 
if errorlevel 1 exit 1

:: Build!
nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
>>>>>>> Process feedback of @patricksnape
=======
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
>>>>>>> Started with sdl2 recipes
=======
@echo off
:: MSVC library for Python 2.7 is not found automaticaly if it is 
:: installed in the user's AppData folder. Add it to PATH
setlocal EnableDelayedExpansion

if "%PY_VER%"=="2.7" (
	set VC9DIR=%LOCALAPPDATA%\Programs\Common\Microsoft\Visual C++ for Python\9.0
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

call %LIBRARY_BIN%\cmake .. -G "NMake Makefiles" -D DESTINATION:FILEPATH="%LIBRARY_PREFIX%"
if errorlevel 1 exit 1

nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
>>>>>>> Progress on bld.bat
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
if errorlevel 1 exit 1
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
if errorlevel 1 exit 1
>>>>>>> Builds working on all Windows options
=======
:: MSVC library for Python 2.7 is not found automaticaly if it is 
:: installed in the user's AppData folder. Add it to PATH
setlocal EnableDelayedExpansion

set TARGET=Release
:: Set target back to Debug for 64-bits builds with VS2008 and VS2010
if %VS_MAJOR% LSS 14 (
	if %ARCH% == 64 (
		set TARGET=Debug
	)
)

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
if errorlevel 1 exit 1
>>>>>>> add patch req., add autoconf, fix win target
=======
:: MSVC library for Python 2.7 is not found automaticaly if it is 
:: installed in the user's AppData folder. Add it to PATH
setlocal EnableDelayedExpansion

set TARGET=Release
:: Set target back to Debug for 64-bits builds with VS2008 and VS2010
if %VS_MAJOR% LSS 14 (
	if %ARCH% == 64 (
		set TARGET=Debug
	)
)

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
	set DIRECTX_FLAG="-DDIRECTX=OFF"
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
if errorlevel 1 exit 1
>>>>>>> small commit to restart builds
