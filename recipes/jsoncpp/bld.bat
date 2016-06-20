mkdir build
if errorlevel 1 exit 1

cd build
if errorlevel 1 exit 1

cmake .. ^
        -G %CMAKE_GENERATOR% ^
        -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
        -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
        -DBUILD_STATIC_LIBS=1 ^
        -DBUILD_SHARED_LIBS=1 ^
        -DPYTHON_EXECUTABLE="%PYTHON%"
if errorlevel 1 exit 1

cmake --build . --config Release
if errorlevel 1 exit 1

cmake --build . --config Release --target install
if errorlevel 1 exit 1

ctest
if errorlevel 1 exit 1
