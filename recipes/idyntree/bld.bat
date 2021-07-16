mkdir build
cd build

cmake ^
    -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_TESTING=ON ^
    -DIDYNTREE_USES_IPOPT:BOOL=ON ^
    -DIDYNTREE_USES_OSQPEIGEN:BOOL=ON ^
    -DIDYNTREE_USES_IRRLICHT:BOOL=ON ^
    -DIDYNTREE_USES_MATLAB:BOOL=OFF ^
    -DIDYNTREE_USES_PYTHON:BOOL=ON ^
    -DIDYNTREE_USES_OCTAVE:BOOL=OFF ^
    -DIDYNTREE_USES_LUA:BOOL=OFF ^
    -DIDYNTREE_COMPILES_YARP_TOOLS:BOOL=OFF ^
    -DIDYNTREE_DETECT_ACTIVE_PYTHON_SITEPACKAGES:BOOL=ON ^
    %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1

:: Test.
ctest --output-on-failure -C Release 
if errorlevel 1 exit 1


