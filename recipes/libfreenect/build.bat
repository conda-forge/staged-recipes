@echo on

mkdir build && cd build

REM Remove ancient FindThreads
del %SRC_DIR%\cmake_modules\FindThreads.cmake

cmake %CMAKE_ARGS% ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DBUILD_EXAMPLES=OFF ^
    -DBUILD_FAKENECT=ON ^
    -DBUILD_C_SYNC=OFF ^
    -DBUILD_CPP=ON ^
    -DBUILD_CV=OFF ^
    -DBUILD_PYTHON=OFF ^
    -DBUILD_PYTHON2=OFF ^
    -DBUILD_PYTHON3=OFF ^
    -DBUILD_REDIST_PACKAGE=ON ^
    ..
if errorlevel 1 exit /b 1

cmake --build . --config Release
if errorlevel 1 exit /b 1

cmake --install . --config Release
if errorlevel 1 exit /b 1