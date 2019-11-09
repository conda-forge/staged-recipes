mkdir build
cd build

cmake ^
    -G "Ninja" ^
    -DCMAKE_C_COMPILER=clang-cl ^
    -DCMAKE_CXX_COMPILER=clang-cl ^
    -DBoost_NO_BOOST_CMAKE=ON ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DDCGP_BUILD_TESTS=no ^
    -DDCGP_BUILD_EXAMPLES=no ^
    ..

cmake --build . -- -v

cmake --build . --target install

cd ..
mkdir build_python
cd build_python

cmake ^
    -G "Ninja" ^
    -DCMAKE_C_COMPILER=clang-cl ^
    -DCMAKE_CXX_COMPILER=clang-cl ^
    -DBoost_NO_BOOST_CMAKE=ON ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DDCGP_BUILD_DCGP=no ^
    -DDCGP_BUILD_DCGPY=yes ^
    "-DDCGP_CXX_FLAGS_EXTRA=-D_copysign=copysign;-Dand=&&;-Dnot=!" ^
    ..

cmake --build . -- -v

cmake --build . --target install
