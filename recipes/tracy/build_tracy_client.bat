rm -rf build

mkdir build
cd build

cmake .. ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DBUILD_SHARED_LIBS=ON ^
    -GNinja ^
    -DCMAKE_INSTALL_PREFIX:PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_PREFIX_PATH:PATH="%LIBRARY_PREFIX%"

:: build
cmake --build . --parallel %CPU_COUNT%

:: install
cmake --build . --target install
