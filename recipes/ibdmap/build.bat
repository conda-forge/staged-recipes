:: Create a separate build directory
mkdir build
cd build

:: Configure the project using CMake
cmake -G "Ninja" ^
      %CMAKE_ARGS% ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      %SRC_DIR%
if errorlevel 1 exit 1

:: Compile the project
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install the project
cmake --install . --config Release
if errorlevel 1 exit 1
