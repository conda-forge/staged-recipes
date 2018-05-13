dir

7za x lts\ldc2-1.9.0-windows-x64.7z -o%SRC_DIR%\lts

mkdir build
cd build
cmake -G Ninja ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
      -DBUILD_SHARED_LIBS=ON ^
      -DD_COMPILER=%SRC_DIR%\lts\ldc2-1.9.0-windows-x64\bin\ldmd2.exe ^
      ..
ninja install
ldc2 -version

