
mkdir build && cd build

set CMAKE_CONFIG="Release"

cmake -LAH -G"NMake Makefiles"                               ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%"                   ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"                ^
    -DPYTHON_INSTALL="%SP_DIR%"                              ^
    -DBUILD_SHARED_LIBS=OFF                                  ^
    ..
if errorlevel 1 exit 1

cmake --build . --config %CMAKE_CONFIG% --target install
if errorlevel 1 exit 1

%PYTHON% ..\wrappers\pyAgrum\testunits\TestSuite.py
if errorlevel 1 exit 1

