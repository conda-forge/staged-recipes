cd test
mkdir build
cd build
cmake .. -GNinja -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% -DCMAKE_BUILD_TYPE=Release
ninja
test.exe
