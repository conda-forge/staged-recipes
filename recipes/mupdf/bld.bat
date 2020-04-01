@echo off
setlocal EnableDelayedExpansion

copy "%RECIPE_DIR%\\CMakeLists.txt" .
if errorlevel 1 exit 1

:: Make a build folder and change to it.
mkdir build
cd build

set VERBOSE=1
:: Configure using the CMakeFiles
::cmake -G "NMake Makefiles" ^
::cmake -G "Visual Studio 14 2015 Win64" ^
cmake -G Ninja ^
      -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
      -DCMAKE_BUILD_TYPE:STRING=Release ^
      ..
if errorlevel 1 exit 1

:: Build!
::nmake
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install!
nmake install
if errorlevel 1 exit 1

:: build system uses non-standard env vars
::set XCFLAGS=%CFLAGS% -I"%LIBRARY_PREFIX%\\include"
::set XLIBS=%LIBS%
::set USE_SYSTEM_LIBS=yes
::set USE_SYSTEM_JPEGXR=yes

:: diagnostics
::dir %LIBRARY_PREFIX%\\include

:: build and install
::make "prefix=%LIBRARY_PREFIX%" -j %CPU_COUNT% all
::if errorlevel 1 exit 1
:: no make check
::make "prefix=%LIBRARY_PREFIX%" install
::if errorlevel 1 exit 1
