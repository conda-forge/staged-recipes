setlocal EnableDelayedExpansion

cd "libmikmod-3.1.12.patched"

copy %RECIPE_DIR%\CMakeLists.txt .\CMakeLists.txt

:: Make a build folder and change to it.
mkdir build
cd build

:: Configure using the CMakeFiles
%LIBRARY_BIN%\cmake -G "NMake Makefiles" .. 
if errorlevel 1 exit 1

:: Build!
nmake
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1