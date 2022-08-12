mkdir build
cd build

set "CC=clang-cl.exe"
set "CXX=clang-cl.exe"
set "CL=/MP"

::Configure
cmake ^
    -G "NMake Makefiles" ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DPYTHON_SITELIB=%SP_DIR% ^
    -DPYTHON_EXECUTABLE=%PYTHON% ^
    -DBUILD_PYTHON_INTERFACE=ON ^
    -DINSTALL_DOCUMENTATION=ON ^
    -DBUILD_WITH_VECTORIZATION_SUPPORT=ON ^
    -DBUILD_TESTING=OFF ^
    %SRC_DIR%
if errorlevel 1 exit 1

:: Build.
cmake --build . --config Release
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install
if errorlevel 1 exit 1
