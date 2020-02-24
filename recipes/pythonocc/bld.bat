mkdir build
cd build

cmake -G "Ninja" ^
    -D CMAKE_INSTALL_PREFIX:FILEPATH="%LIBRARY_PREFIX%" ^
    -D PYTHONOCC_BUILD_TYPE:STRING=Release ^
    -D Python3_FIND_STRATEGY:STRING=LOCATION ^
    -D Python3_FIND_REGISTRY:STRING=NEVER ^
    -D SWIG_HIDE_WARNINGS:BOOL=ON ^
    ..

if errorlevel 1 exit 1

ninja install
if errorlevel 1 exit 1