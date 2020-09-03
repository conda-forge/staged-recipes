mkdir build && cd build

cmake -LAH -G"NMake Makefiles" ^
    -DCMAKE_PREFIX_PATH="%PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DDEBUG=OFF ^
    -DOPENMP=set ^
    -DBUILD_SHARED_LIBS=ON ^
    ..
if errorlevel 1 exit 1

cmake --build . --config "Release"
if errorlevel 1 exit 1

cmake --install .
if errorlevel 1 exit 1
