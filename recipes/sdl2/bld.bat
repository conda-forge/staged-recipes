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
%LIBRARY_BIN%\cmake -G "NMake Makefiles" -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" -DCMAKE_BUILD_TYPE:STRING=!TARGET! !DIRECTX_FLAG! .. 
if errorlevel 1 exit 1

:: Build!
nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
