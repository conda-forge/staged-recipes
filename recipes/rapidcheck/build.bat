 mkdir build
  cd build
  cmake ^
    -DCMAKE_INSTALL_PREFIX=%CONDA_PREFIX% ^
    -DBUILD_SHARED_LIBS=ON ^
    ..
  cmake --build . --config Release 
  cmake --build . --config Release --target install
