setlocal EnableDelayedExpansion

mkdir build
cd build

set "CC=clang-cl.exe"
set "CXX=clang-cl.exe"
set "CL=/MP"

::Configure
cmake ^
    %SRC_DIR% ^
    -G Ninja ^
    -DOGRE_DIR="%LIBRARY_PREFIX%\cmake" ^
    -DCMAKE_BUILD_TYPE:STRING=Release ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DVISP_LIB_INSTALL_PATH:PATH="lib" ^
    -DVISP_BIN_INSTALL_PATH:PATH="bin" ^
    -DVISP_CONFIG_INSTALL_PATH:PATH="cmake" ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DBUILD_TESTS=ON
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