mkdir build
cd build
cmake -G Ninja ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
      -DBUILD_SHARED_LIBS=ON ^
      -DD_COMPILER=%SRC_DIR%\lts\bin\ldmd2.exe ^
      ..
ninja install
ldc2 -version

