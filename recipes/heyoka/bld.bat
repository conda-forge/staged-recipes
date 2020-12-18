mkdir build
cd build

cmake ^
    -G "Ninja" ^
    -DCMAKE_C_COMPILER=clang-cl ^
    -DCMAKE_CXX_COMPILER=clang-cl ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DHEYOKA_BUILD_TESTS=yes ^
    -DHEYOKA_ENABLE_IPO=yes ^
    -DHEYOKA_WITH_SLEEF=yes ^
    -DBoost_NO_BOOST_CMAKE=ON ^
    ..

cmake --build . -- -v

set PATH=%PATH%;%CD%

ctest --output-on-failure -j${CPU_COUNT}

cmake --build . --target install
