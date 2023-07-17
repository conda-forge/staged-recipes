setlocal EnableDelayedExpansion

mkdir build
cd build

::Configure
cmake ^
    %SRC_DIR% ^
    -G Ninja ^
    -DCMAKE_BUILD_TYPE:STRING=Release ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DSOFA_ENABLE_LEGACY_HEADERS=OFF ^
    -DSOFA_BUILD_TESTS=OFF
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

:: Test
ctest --parallel "%CPU_COUNT%"
if errorlevel 1 exit 1