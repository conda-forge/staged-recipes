setlocal EnableDelayedExpansion

mkdir build
cd build

::Configure
cmake ^
    %CMAKE_ARGS% ^
    -B . ^
    -S %SRC_DIR% ^
    -G Ninja ^
    -DCMAKE_BUILD_TYPE:STRING=Release ^
    -DSOFA_ENABLE_LEGACY_HEADERS:BOOL=OFF ^
    -DSOFA_BUILD_TESTS:BOOL=OFF
if errorlevel 1 exit 1

:: Build.
cmake --build . --parallel "%CPU_COUNT%"
if errorlevel 1 exit 1

:: We have to create empty directories that are usually created by hand
:: when installing the SOFA "Windows Dependency Package", in which case 
:: they would contain some dependencies that are here installed as conda packages
:: See https://www.sofa-framework.org/community/doc/getting-started/build/windows/
:: Without these dummy directories, the install would fail
mkdir "%SRC_DIR%\include"
mkdir "%SRC_DIR%\licenses"

:: Install.
cmake --build . --parallel "%CPU_COUNT%" --target install
if errorlevel 1 exit 1

:: Fix incorrectly installed SceneChecking.dll file on Windows build (required for runSofa.exe)
copy "%LIBRARY_PREFIX%\plugins\SceneChecking\bin\SceneChecking.dll" "%LIBRARY_BIN%"
:: Fix incorrectly installed CImgPlugin.dll file on Windows build (required for SofaMatrix.dll)
copy "%LIBRARY_PREFIX%\plugins\CImgPlugin\bin\CImgPlugin.dll" "%LIBRARY_BIN%"

:: Test
ctest --parallel "%CPU_COUNT%"
if errorlevel 1 exit 1