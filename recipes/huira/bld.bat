@echo off

echo Building %PKG_NAME% version %PKG_VERSION%

cmake -B build ^
    -G Ninja ^
    %CMAKE_ARGS% ^
    -DCMAKE_CXX_SCAN_FOR_MODULES=OFF ^
    -DHUIRA_APPS=ON ^
    -DHUIRA_PYTHON=ON ^
    -DPython_EXECUTABLE="%PYTHON%"
if errorlevel 1 exit 1

cmake --build build --parallel %CPU_COUNT%
if errorlevel 1 exit 1

cmake --install build
if errorlevel 1 exit 1
