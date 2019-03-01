cd test
mkdir build
cd build
cmake .. -GNinja -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% -DCMAKE_LIBRARY_PATH:PATH=%LIBRARY_PREFIX%\lib
ninja
test.exe
