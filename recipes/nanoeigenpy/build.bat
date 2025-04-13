setlocal EnableDelayedExpansion

rd /q /s build

mkdir build
cd build


::Configure
cmake ^
    -G Ninja ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_WITH_CHOLDMOD_SUPPORT=ON ^
    -DPython_EXECUTABLE=%PYTHON% ^
    -DBUILD_TESTING=OFF ^
    %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1