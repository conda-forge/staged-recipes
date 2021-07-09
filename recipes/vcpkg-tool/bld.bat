setlocal EnableDelayedExpansion
setlocal enableextensions

MKDIR build
CD build

cmake .. ^
	-G "Ninja" ^
	-DCMAKE_BUILD_TYPE=Release ^
	-DVCPKG_DEVELOPMENT_WARNINGS=OFF ^
	%CMAKE_ARGS%

if errorlevel 1 exit 1

ninja
@rem ninja test

if errorlevel 1 exit 1

IF NOT EXIST %LIBRARY_PREFIX%\bin MKDIR %LIBRARY_PREFIX%\bin
COPY vcpkg.exe %LIBRARY_PREFIX%\bin\
if errorlevel 1 exit 1