mkdir build
cd build

cmake -G "Ninja" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_TESTING:BOOL=ON ^
    -DBUILD_SHARED_LIBS:BOOL=ON ^
    -DFRAMEWORK_USE_YARP:BOOL=ON ^
    -DFRAMEWORK_USE_OsqpEigen:BOOL=ON ^
    -DFRAMEWORK_USE_matioCpp:BOOL=ON ^
    -DFRAMEWORK_USE_manif:BOOL=ON ^
    -DFRAMEWORK_USE_Qhull:BOOL=ON ^
    -DFRAMEWORK_USE_cppad:BOOL=ON ^
    -DFRAMEWORK_USE_casadi:BOOL=ON ^
    -DFRAMEWORK_USE_LieGroupControllers:BOOL=ON ^
    -DFRAMEWORK_USE_UnicyclePlanner:BOOL=ON ^
    -DFRAMEWORK_COMPILE_PYTHON_BINDINGS:BOOL=OFF ^
    %SRC_DIR%
if errorlevel 1 exit 1

type CMakeCache.txt

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1

:: Test.
ctest --output-on-failure -C Release 
if errorlevel 1 exit 1
