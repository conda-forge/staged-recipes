mkdir build && cd build

cmake ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_LIBDIR=%LIBRARY_LIB% ^
    -DLIB3MF_TESTS=OFF ^
    -G "NMake Makefiles" ^
    ..

cmake --build . --config Release --target install
if errorlevel 1 exit 1
