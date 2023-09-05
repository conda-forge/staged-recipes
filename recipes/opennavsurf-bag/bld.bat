setlocal EnableDelayedExpansion

mkdir build
if errorlevel 1 exit 1

if  %vc% LEQ 9 set MSVC_VER=1500
if  %vc% GTR 9 set MSVC_VER=1900

if  %vc% LEQ 9 set MSVC_TS_VER=90
if  %vc% GTR 9 set MSVC_TS_VER=140

REM Configure CMake build
cmake -G Ninja ^
	-DCMAKE_BUILD_TYPE=Release ^
	-B build -S "%SRC_DIR%" ^
	-DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
	-DCMAKE_INSTALL_LIBDIR=lib ^
    -DMSVC_VERSION="%MSVC_VER%" ^
    -DMSVC_TOOLSET_VERSION="%MSVC_TS_VER%" ^
    -DBUILD_SHARED_LIBS=ON ^
	-DBAG_CI:BOOL=ON ^
	-DBAG_BUILD_TESTS:BOOL=OFF ^
	-DBAG_BUILD_PYTHON:BOOL=OFF ^
	-DCMAKE_OBJECT_PATH_MAX=1024
	
if errorlevel 1 exit /b 1

REM Build C++
cmake --build build -j %CPU_COUNT% --config Release
if errorlevel 1 exit /b 1

REM Build Python wheel
%PYTHON% -m pip wheel -w .\wheel .\build\api\swig\python
if errorlevel 1 exit /b 1

REM Install it
cmake --install build
if errorlevel 1 exit /b 1
for %%w in (.\wheel\bagPy-*.whl) do %PYTHON% -m pip install %%w
if errorlevel 1 exit /b 1
