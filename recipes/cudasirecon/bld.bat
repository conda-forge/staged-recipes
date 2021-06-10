mkdir cmake_build
cd cmake_build

cmake -G Ninja ^
    -DBUILD_MRC=OFF ^
    -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_BUILD_TYPE=Release ^
    ../src

if errorlevel 1 exit 1

ninja
if errorlevel 1 exit 1

ninja install
if errorlevel 1 exit 1