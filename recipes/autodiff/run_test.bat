cd test
mkdir build
cd build
cmake .. -GNinja -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX%
ninja
test.exe
