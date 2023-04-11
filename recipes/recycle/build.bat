  mkdir build
  cd build
  cmake ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    ..
  cmake --build . --config Release 
  cmake --build . --config Release --target install