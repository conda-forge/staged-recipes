setlocal EnableDelayedExpansion

mkdir build
cd build

set "CC=clang-cl.exe"
set "CXX=clang-cl.exe"
set "CL=/MP"
set "OGRE_DIR=%PREFIX%\Library\cmake"

::Configure
cmake ^
    %SRC_DIR% ^
    -G Ninja ^
    -DCMAKE_BUILD_TYPE:STRING=Release ^
    -DBUILD_TESTS=ON
if errorlevel 1 exit 1

:: Build.
cmake --build . --parallel "%CPU_COUNT%" --verbose
if errorlevel 1 exit 1

:: test
ctest --parallel "%CPU_COUNT%" --verbose
if errorlevel 1 exit 1

:: Install.
cmake --build . --parallel "%CPU_COUNT%" --verbose --target install
if errorlevel 1 exit 1