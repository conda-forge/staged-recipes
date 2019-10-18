mkdir build
cd build

cmake ^
    -G "NMake Makefiles" ^
    -DCMAKE_C_COMPILER=clang-cl ^
    -DCMAKE_CXX_COMPILER=clang-cl ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DOBAKE_BUILD_TESTS=yes ^
    ..

cmake --build .

set PATH=%PATH%;%CD%

ctest

cmake --build . --target install
