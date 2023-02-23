mkdir build
cd build

cmake -G "Visual Studio 16 2019" -A x64 ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCASCADE_BUILD_TESTS=yes ^
    -DBoost_NO_BOOST_CMAKE=ON ^
    -DCASCADE_BUILD_PYTHON_BINDINGS=yes ^
    ..

cmake --build . --config RelWithDebInfo --target install

