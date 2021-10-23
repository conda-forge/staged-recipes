set section=##[section]

echo.
echo %section%====================
echo %section%Building libscenario
echo %section%====================
echo.

:: Print the CI environment
echo ##[group] Environment
set
echo ##[endgroup]
echo.

:: Configure the CMake project
cmake ^
    -S .\scenario\ ^
    -B build\ ^
    -GNinja ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_PREFIX:PATH=%LIBRARY_PREFIX% ^
    -DSCENARIO_USE_IGNITION:BOOL=ON ^
    -DSCENARIO_ENABLE_BINDINGS:BOOL=OFF
if errorlevel 1 exit 1

:: Compile the CMake project
cmake --build build\
if errorlevel 1 exit 1

:: Install the CMake project
cmake --install build\
if errorlevel 1 exit 1

:: TODO: activate / deactivate

echo %section%Finishing: building libscenario
