@REM Build and execute the C++ test application
cd test
mkdir build
cd build
cmake -GNinja .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=$PREFIX
ninja
app.exe
