cd test
mkdir build
cd build
cmake .. -GNinja -DCMAKE_PREFIX_PATH=%PREFIX%
ninja
test.exe
