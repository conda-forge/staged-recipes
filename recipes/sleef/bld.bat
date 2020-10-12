mkdir build
cd build

cmake ^
    -G"Visual Studio 15 2017" ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    ..

cmake --build . --target install --config Release
