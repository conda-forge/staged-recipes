mkdir build
cd build

set CONFIGURATION=Release

cmake .. -G "NMake Makefiles" ^
    -DCMAKE_BUILD_TYPE=%CONFIGURATION% ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DPYTHON_EXECUTABLE="%PYTHON%"

if errorlevel 1 exit 1

nmake all
if errorlevel 1 exit 1

nmake install
if errorlevel 1 exit 1
