@REM Execute the Python test application using reaktplot
python test/example.py

@REM Build and execute the C++ test application using reaktplot
cd test/app
mkdir build
cd build
cmake -GNinja ..                         ^
    -DCMAKE_BUILD_TYPE=Release           ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX%
ninja
app.exe
