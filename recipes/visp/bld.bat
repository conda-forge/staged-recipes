setlocal EnableDelayedExpansion

mkdir build
cd build

set "CC=clang-cl.exe"
set "CXX=clang-cl.exe"
set "CL=/MP"
:: Hints OGRE to find its CMake module file
set "OGRE_DIR=%LIBRARY_PREFIX%\cmake"


::Configure
cmake ^
    %CMAKE_ARGS% ^
    %SRC_DIR% ^
    -G Ninja ^
    -DBUILD_TESTS=ON ^
    -DOGRE_DIR="%OGRE_DIR%" ^
    -DCMAKE_BUILD_TYPE:STRING=Release ^
    -DVISP_LIB_INSTALL_PATH:PATH="lib" ^
    -DVISP_BIN_INSTALL_PATH:PATH="bin" ^
    -DVISP_CONFIG_INSTALL_PATH:PATH="cmake"
if errorlevel 1 exit 1

:: Build.
cmake --build . --parallel "%CPU_COUNT%"
if errorlevel 1 exit 1

:: Install.
cmake --build . --parallel "%CPU_COUNT%" --target install
if errorlevel 1 exit 1

:: Test
ctest --parallel "%CPU_COUNT%"
if errorlevel 1 exit 1