mkdir build
cd build

cmake -LAH -G"NMake Makefiles"                               ^
    -DPython3_EXECUTABLE="%PYTHON%"                          ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%"                   ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%"                ^
    -DKDDockWidgets_QT6=false                                ^
    -DKDDockWidgets_STATIC=false                             ^
    -DKDDockWidgets_EXAMPLES=false                           ^
    -DKDDockWidgets_PYTHON_BINDINGS=true                     ^
    -DCMAKE_BUILD_TYPE=Release                               ^
    ..
if errorlevel 1 exit 1

cmake --build . --target install
if errorlevel 1 exit 1