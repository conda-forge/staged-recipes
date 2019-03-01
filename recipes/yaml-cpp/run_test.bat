cd test
if errorlevel 1 exit 1

mkdir build
if errorlevel 1 exit 1

cd build
if errorlevel 1 exit 1

cmake .. ^
    -GNinja ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_LIBRARY_PATH:PATH=%LIBRARY_PREFIX%\lib ^
    -DCMAKE_VERBOSE_MAKEFILE=ON
echo "CMake finished"
if errorlevel 1 exit 1
echo "CMake okay"

ninja
echo "Ninja finished"
if errorlevel 1 exit 1
echo "Ninja okay"

test.exe
echo "Test finished"
if errorlevel 1 exit 1
echo "Test okay"
