mkdir build
if errorlevel 1 exit 1

if  %vc% LEQ 9 set MSVC_VER=1500
if  %vc% GTR 9 set MSVC_VER=1900

if  %vc% LEQ 9 set MSVC_TS_VER=90
if  %vc% GTR 9 set MSVC_TS_VER=140

REM Configure CMake build
cmake -B build -G Ninja ^
	"%CMAKE_ARGS%" ^
    -DMSVC_VERSION="%MSVC_VER%" ^
    -DMSVC_TOOLSET_VERSION="%MSVC_TS_VER%" ^
	-DCMAKE_BUILD_TYPE=Release ^
	-DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
    -DBUILD_SHARED_LIBS=ON ^
	-DBAG_BUILD_TESTS:BOOL=OFF ^
	-DBAG_BUILD_PYTHON:BOOL=ON ^
	"%SRC_DIR%"

if errorlevel 1 exit /b 1

REM Build it
cmake --build build -j %CPU_COUNT% --verbose --config Release

if errorlevel 1 exit /b 1

REM Install it
%PYTHON% .\build\api\swig\python\setup.py install
if errorlevel 1 exit /b 1
cmake --install build

if errorlevel 1 exit /b 1

REM Test it (only do Python tests for now due to linkage errors with
REM   catch2 under MSVC)
set BAG_SAMPLES_PATH=examples\sample-data
%PYTHON% -m pytest "%SRC_DIR%\python\test_*.py"
